{
  mkCidr = ip: mask: "${ip}/${toString mask}";
}
