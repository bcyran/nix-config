#!/usr/bin/env bash
# Dix closure diff — build Nix closures for the base and head commits of a
# pull request, diff each pair with dix, and post the result as a PR comment.
#
# Intended to run as the step of the .forgejo/dix-diff composite action, but
# can also be run by hand: set DIX_DRY_RUN=1 to print the comment body instead
# of posting it to Forgejo.
set -euo pipefail

log() { printf 'dix-diff: %s\n' "$*" >&2; }
die() {
  log "error: $*"
  exit 1
}

: "${DIX_BASE_SHA:?DIX_BASE_SHA is required}"
: "${DIX_HEAD_SHA:?DIX_HEAD_SHA is required}"
: "${DIX_PR_NUMBER:?DIX_PR_NUMBER is required}"

repo="${FORGEJO_REPOSITORY:-${GITHUB_REPOSITORY:-}}"
api="${FORGEJO_API_URL:-${GITHUB_API_URL:-}}"
token="${FORGEJO_TOKEN:-${GITHUB_TOKEN:-}}"

[[ -n "${repo}" ]] || die "FORGEJO_REPOSITORY is not set"
[[ -n "${api}" ]] || die "FORGEJO_API_URL is not set"
[[ -n "${token}" ]] || die "no Forgejo token is available"
command -v nix > /dev/null || die "nix is not in PATH"
command -v dix > /dev/null || die "dix is not in PATH"
command -v jq > /dev/null || die "jq is not in PATH"

read -r -d '' -a closures <<< "${DIX_CLOSURES}" || true

labels=()
attrs=()
for entry in "${closures[@]:-}"; do
  [[ -n "${entry}" ]] || continue
  case "${entry}" in
    *=*)
      labels+=("${entry%%=*}")
      attrs+=("${entry#*=}")
      ;;
    *)
      labels+=("${entry}")
      attrs+=("${entry}")
      ;;
  esac
done

work="$(mktemp -d)"
cleanup() {
  if [[ -n "${base_dir:-}" ]] && [[ -d "${base_dir}" ]]; then
    git worktree remove --force "${base_dir}" 2> /dev/null || rm -rf "${base_dir}"
  fi
  git worktree prune 2> /dev/null || true
  rm -rf "${work}"
}
trap cleanup EXIT

if [[ "${DIX_BASE_SHA}" = "${DIX_HEAD_SHA}" ]]; then
  log "base and head are the same commit (${DIX_BASE_SHA}); nothing to diff"
  exit 0
fi

base_dir="${work}/base"
if ! git worktree add --detach "${base_dir}" "${DIX_BASE_SHA}" 2> /dev/null; then
  git fetch origin "${DIX_BASE_SHA}" 2> /dev/null || true
  git worktree add --detach "${base_dir}" "${DIX_BASE_SHA}" \
    || die "could not check out base commit ${DIX_BASE_SHA}"
fi

build() { # flake out-link attribute
  local flake="$1" out="$2" attr="$3"
  log "building ${attr} from ${flake}"
  nix build --out-link "${out}" "${flake}#${attr}" 2> "${work}/build.log" \
    || {
      sed 's/^/  /' "${work}/build.log" >&2
      return 1
    }
}

write_section() { # label content
  local label="$1" content="$2"
  printf '<details>\n<summary>%s</summary>\n\n%s\n\n</details>\n\n' "${label}" "${content}"
}

{
  printf '## Closure diffs: `%s` -> `%s`\n\n' "${DIX_BASE_SHA:0:12}" "${DIX_HEAD_SHA:0:12}"
  printf '%s\n\n' "_Automated report from the dix action. This comment is replaced on every push to the PR._"

  for i in "${!attrs[@]}"; do
    attr="${attrs[${i}]}"
    label="${labels[${i}]}"
    slug="$(printf '%s' "${attr}" | tr -c 'A-Za-z0-9._-' '_')"

    if ! build "${base_dir}" "${work}/base-${slug}" "${attr}"; then
      write_section "${label}" "Build of the base closure failed. See the workflow log for details."
    elif ! build "." "${work}/head-${slug}" "${attr}"; then
      write_section "${label}" "Build of the head closure failed. See the workflow log for details."
    else
      base_out="$(readlink -f "${work}/base-${slug}")"
      head_out="$(readlink -f "${work}/head-${slug}")"
      if out="$(dix --force-correctness --color never "${base_out}" "${head_out}" 2> "${work}/dix.err")"; then
        [[ -n "${out}" ]] || out="No changes."
      else
        out="dix failed: $(head -c 300 "${work}/dix.err" 2> /dev/null || true)"
      fi
      write_section "${label}" $'```text\n'"${out}"$'\n```'
    fi
  done

  printf '%s\n' "<!-- dix-diff -->"
} > "${work}/comment.md"

if [[ "${DIX_DRY_RUN:-0}" = "1" ]]; then
  log "dry run; comment would be:"
  cat "${work}/comment.md" >&2
  exit 0
fi

bot_id="$(
  curl -fsS -H "Authorization: token ${token}" \
    "${api}/repos/${repo}/issues/${DIX_PR_NUMBER}/comments?limit=100" \
    | jq -r '.[] | select(.body | contains("dix-diff")) | .id' \
    | head -n 1
)" || die "failed to list comments on PR #${DIX_PR_NUMBER}"

if [[ -n "${bot_id}" ]]; then
  log "removing previous comment ${bot_id}"
  curl -fsS -X DELETE -H "Authorization: token ${token}" \
    "${api}/repos/${repo}/issues/comments/${bot_id}" > /dev/null \
    || log "warning: could not delete previous comment ${bot_id}"
fi

body="$(jq -Rs . < "${work}/comment.md")"
curl -fsS -X POST \
  -H "Authorization: token ${token}" \
  -H "Content-Type: application/json" \
  --data "{\"body\": ${body}}" \
  "${api}/repos/${repo}/issues/${DIX_PR_NUMBER}/comments" > /dev/null \
  || die "failed to post comment on PR #${DIX_PR_NUMBER}"

log "posted comment on PR #${DIX_PR_NUMBER}"

