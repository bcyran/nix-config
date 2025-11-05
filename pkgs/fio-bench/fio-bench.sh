#!/usr/bin/env bash

# CrystalDiskMark style disk benchmark script.
# Usage: ./benchmark.sh [OPTIONS] /path/to/test [size_in_GB]
# Options:
#   -r, --results <dir>   Print results from existing directory without re-running
#   -n, --name <name>     Name for this test run (used in results directory)
#   -h, --help            Show this help message

set -e

# Function to show help
show_help() {
  cat << EOF
Usage: $0 [OPTIONS] /path/to/test [size_in_GB]

CrystalDiskMark style disk benchmark using fio.

OPTIONS:
  -r, --results <dir>   Print results from existing directory without re-running
  -n, --name <name>     Name for this test run (used in results directory)
  -h, --help            Show this help message

ARGUMENTS:
  /path/to/test         Directory to run benchmarks in (default: current directory)
  size_in_GB            Size of test file in GB (default: 4G)

EXAMPLES:
  $0 /mnt/disk 8        Run benchmark on /mnt/disk with 8GB test file
  $0 -n ssd_test /tmp   Run benchmark with custom name
  $0 -r fio_results_*   Print results from previous run

TESTS PERFORMED:
  - SEQ1M Q8T1: Sequential 1MB read/write, queue depth 8
  - SEQ1M Q1T1: Sequential 1MB read/write, queue depth 1
  - RND4K Q32T1: Random 4K read/write, queue depth 32
  - RND4K Q1T1: Random 4K read/write, queue depth 1

Each test runs for 60 seconds. Total runtime ~10 minutes.
EOF
  exit 0
}

# Parse options
PRINT_ONLY=false
TEST_NAME=""
while [[ $# -gt 0 ]]; do
  case $1 in
    -h | --help)
      show_help
      ;;
    -r | --results)
      PRINT_ONLY=true
      RESULTS_DIR="$2"
      shift 2
      ;;
    -n | --name)
      TEST_NAME="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

# Show help if no arguments provided
if [[ $# -eq 0 && "${PRINT_ONLY}" = false ]]; then
  show_help
fi

# Configuration
TARGET_DIR="${1:-.}"
TEST_SIZE="${2:-4}G"
if [[ "${PRINT_ONLY}" = false ]]; then
  if [[ -n "${TEST_NAME}" ]]; then
    RESULTS_DIR="fio_results_${TEST_NAME}_$(date +%Y%m%d_%H%M%S)"
  else
    RESULTS_DIR="fio_results_$(date +%Y%m%d_%H%M%S)"
  fi
fi
TEST_FILE="${TARGET_DIR}/fio_testfile"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print results summary
print_summary() {
  local results_dir=$1

  echo -e "${GREEN}=== Benchmark Summary ===${NC}"
  echo "Results from: ${results_dir}"
  echo ""

  echo "SEQ1M Q8T1:"
  echo "  Read:  $(parse_result "${results_dir}/seq1m_q8t1_read.json" "read")"
  echo "  Write: $(parse_result "${results_dir}/seq1m_q8t1_write.json" "write")"
  echo ""
  echo "SEQ1M Q1T1:"
  echo "  Read:  $(parse_result "${results_dir}/seq1m_q1t1_read.json" "read")"
  echo "  Write: $(parse_result "${results_dir}/seq1m_q1t1_write.json" "write")"
  echo ""
  echo "RND4K Q32T1:"
  echo "  Read:  $(parse_result "${results_dir}/rnd4k_q32t1_read.json" "read")"
  echo "  Write: $(parse_result "${results_dir}/rnd4k_q32t1_write.json" "write")"
  echo ""
  echo "RND4K Q1T1:"
  echo "  Read:  $(parse_result "${results_dir}/rnd4k_q1t1_read.json" "read")"
  echo "  Write: $(parse_result "${results_dir}/rnd4k_q1t1_write.json" "write")"
  echo ""
}

# Function to parse JSON results
parse_result() {
  local file=$1
  local metric=$2

  if [[ -f "${file}" ]]; then
    if [[ "${metric}" == "read" ]]; then
      jq -r '.jobs[0].read | "BW: \(.bw_mean/1024 | floor)MB/s, IOPS: \(.iops | floor), Lat: \(.lat_ns.mean/1000 | floor)μs"' "${file}"
    else
      jq -r '.jobs[0].write | "BW: \(.bw_mean/1024 | floor)MB/s, IOPS: \(.iops | floor), Lat: \(.lat_ns.mean/1000 | floor)μs"' "${file}"
    fi
  else
    echo "N/A"
  fi
}

# If print-only mode, show results and exit
if [[ "${PRINT_ONLY}" = true ]]; then
  if [[ ! -d "${RESULTS_DIR}" ]]; then
    echo -e "${RED}Error: Results directory '${RESULTS_DIR}' not found${NC}"
    exit 1
  fi
  print_summary "${RESULTS_DIR}"
  exit 0
fi

echo -e "${GREEN}=== FIO Disk Benchmark ===${NC}"
echo "Target: ${TARGET_DIR}"
echo "Test size: ${TEST_SIZE}"
echo "Results: ${RESULTS_DIR}"
echo ""

# Check if fio is installed
if ! command -v fio &> /dev/null; then
  echo -e "${RED}Error: fio is not installed${NC}"
  exit 1
fi

# Create results directory
mkdir -p "${RESULTS_DIR}"

# Cleanup function
cleanup() {
  echo -e "\n${YELLOW}Cleaning up test files...${NC}"
  rm -f "${TEST_FILE}"
}
trap cleanup EXIT

# Run benchmark function
run_benchmark() {
  local name=$1
  local rw=$2
  local bs=$3
  local iodepth=$4
  local numjobs=$5

  echo -e "${GREEN}Running: ${name}${NC}"

  fio --name="${name}" \
    --filename="${TEST_FILE}" \
    --size="${TEST_SIZE}" \
    --rw="${rw}" \
    --bs="${bs}" \
    --iodepth="${iodepth}" \
    --numjobs="${numjobs}" \
    --direct=1 \
    --ioengine=libaio \
    --group_reporting \
    --time_based \
    --runtime=60 \
    --output="${RESULTS_DIR}/${name}.json" \
    --output-format=json

  echo ""
}

echo -e "${YELLOW}Starting benchmarks (this will take ~10 minutes)...${NC}\n"

# SEQ1M Q8T1 - Sequential 1MB blocks, Queue Depth 8, 1 Thread
run_benchmark "seq1m_q8t1_read" "read" "1M" 8 1
run_benchmark "seq1m_q8t1_write" "write" "1M" 8 1

# SEQ1M Q1T1 - Sequential 1MB blocks, Queue Depth 1, 1 Thread
run_benchmark "seq1m_q1t1_read" "read" "1M" 1 1
run_benchmark "seq1m_q1t1_write" "write" "1M" 1 1

# RND4k Q32T1 - Random 4K blocks, Queue Depth 32, 1 Thread
run_benchmark "rnd4k_q32t1_read" "randread" "4k" 32 1
run_benchmark "rnd4k_q32t1_write" "randwrite" "4k" 32 1

# RND4k Q1T1 - Random 4K blocks, Queue Depth 1, 1 Thread
run_benchmark "rnd4k_q1t1_read" "randread" "4k" 1 1
run_benchmark "rnd4k_q1t1_write" "randwrite" "4k" 1 1

# Generate summary
print_summary "${RESULTS_DIR}"

echo -e "${GREEN}Full results saved to: ${RESULTS_DIR}/${NC}"
echo "View detailed JSON results with: jq . ${RESULTS_DIR}/<test>.json"
echo -e "${YELLOW}To reprint these results later: $0 -r ${RESULTS_DIR}${NC}"
