{
  final,
  self,
  system,
}:
{
  # keep-sorted start
  final.apko = self.packages.${system}.apko;
  final.argocd = self.packages.${system}.argocd;
  final.chart-releaser = self.packages.${system}.chart-releaser;
  final.charts-syncer = self.packages.${system}.charts-syncer;
  final.cilium-cli = self.packages.${system}.cilium-cli;
  final.clusterctl = self.packages.${system}.clusterctl;
  final.fluxcd = self.packages.${system}.fluxcd;
  final.gwctl = self.packages.${system}.gwctl;
  final.istioctl = self.packages.${system}.istioctl;
  final.kubernetes-helm = self.packages.${system}.kubernetes-helm;
  final.lazysql = self.packages.${system}.lazysql;
  final.matchbox = self.packages.${system}.matchbox;
  final.packer = self.packages.${system}.packer;
  final.sig = self.packages.${system}.sig;
  final.step-cli = self.packages.${system}.step-cli;
  final.syft = self.packages.${system}.syft;
  final.talosctl = self.packages.${system}.talosctl;
  final.yq-go = self.packages.${system}.yq-go;
  final.zarf = self.packages.${system}.zarf;
  # keep-sorted end
  final.go_1_23 = self.packages.${system}.go-1-23;
  final.go_1_24 = self.packages.${system}.go-1-24;
}
