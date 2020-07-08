import ./make-test-python.nix ({ pkgs, ... }: {
  name = "blockbook";
  meta = with pkgs.stdenv.lib; {
    maintainers = with maintainers; [ maintainers."1000101" ];
  };

  machine = { ... }: {
    services.blockbook = {
      bitcoin = true;
      bitcoinTestnet = true;
    };
  };

  testScript = ''
    start_all()
    machine.wait_for_unit("blockbook-frontend-BTC.service")
    machine.wait_for_unit("blockbook-frontend-TBTC.service")

    machine.wait_for_open_port(9130)
    machine.wait_for_open_port(19130)

    machine.succeed("curl -sSfL http://localhost:9130 | grep 'main'")
    machine.succeed("curl -sSfL http://localhost:19130 | grep 'test'")
  '';
})
