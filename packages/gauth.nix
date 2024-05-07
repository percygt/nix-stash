{
  gauth,
  buildGoModule,
}:
buildGoModule rec {
  pname = "gauth";
  version = gauth.rev;
  src = gauth;
  vendorHash = null;
  meta.mainProgram = "${pname}";
}
