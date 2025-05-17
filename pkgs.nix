{
  final,
  self,
  system,
}:
{
  # keep-sorted start
  final.apko = self.legacyPackages.${system}.apko;
  final.argocd = self.legacyPackages.${system}.argocd;
  final.chart-releaser = self.legacyPackages.${system}.chart-releaser;
  final.charts-syncer = self.legacyPackages.${system}.charts-syncer;
  final.cilium-cli = self.legacyPackages.${system}.cilium-cli;
  final.clusterctl = self.legacyPackages.${system}.clusterctl;
  final.fluxcd = self.packages.${system}.fluxcd;
  final.gwctl = self.legacyPackages.${system}.gwctl;
  final.istioctl = self.legacyPackages.${system}.istioctl;
  final.kubernetes-helm = self.packages.${system}.kubernetes-helm;
  final.lazysql = self.legacyPackages.${system}.lazysql;
  final.matchbox = self.legacyPackages.${system}.matchbox;
  final.packer = self.legacyPackages.${system}.packer;
  final.sig = self.packages.${system}.sig;
  final.step-cli = self.legacyPackages.${system}.step-cli;
  final.syft = self.legacyPackages.${system}.syft;
  final.talosctl = self.packages.${system}.talosctl;
  final.yq-go = self.packages.${system}.yq-go;
  final.zarf = self.packages.${system}.zarf;
  # keep-sorted end
  final.go_1_23 = self.packages.${system}.go-1-23;
  final.go_1_24 = self.packages.${system}.go-1-24;
}
