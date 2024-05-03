{inputs}: {
  vscodeExtensions = system: import ./vscode_extensions.nix {inherit inputs system;};
  inherit (import ./nixGLMesaVulkanWrap.nix) nixGLMesaVulkanWrap;
}
