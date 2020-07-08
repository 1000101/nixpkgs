{ config, lib, pkgs, ... }:

with lib;

let

cfg = config.services.blockbook;

in
{
  options = {
    services.blockbook = {

      bitcoin = mkEnableOption "Bitcoin blockbook + blockchain.";
      bitcoinTestnet = mkEnableOption "Bitcoin blockbook + blockchain (testnet).";

      namecoin = mkEnableOption "Namecoin blockbook + blockchain.";
    };
  };

  config = {

  # Blockchains
    services.bitcoind."mainnet" = mkIf cfg.bitcoin {
      enable = true;
      rpc = {
        port = 8030;
        users.rpc.passwordHMAC = "acc2374e5f9ba9e62a5204d3686616cf$53abdba5e67a9005be6a27ca03a93ce09e58854bc2b871523a0d239a72968033";
      };
    };

    services.bitcoind."testnet" = mkIf cfg.bitcoinTestnet {
      enable = true;
      testnet = true;
      rpc = {
        port = 18030;
        users.rpc.passwordHMAC = "acc2374e5f9ba9e62a5204d3686616cf$53abdba5e67a9005be6a27ca03a93ce09e58854bc2b871523a0d239a72968033";
      };
    };

    services.namecoind = mkIf cfg.namecoin {
      enable = true;
      rpc = {
        port = 8039;
        user = "rpc";
        password = "rpc";
      };
    };
  
  # Blockbook explorers
    services.blockbook-frontend."BTC" = mkIf cfg.bitcoin {
      enable = true;
      openFirewall = true;
      listen.port = 9130;
      #internal.port = 9030;
    };

    services.blockbook-frontend."TBTC" = mkIf cfg.bitcoinTestnet {
      enable = true;
      openFirewall = true;
      rpc = {
        port = 18030;
      };
      listen.port = 19130;
      #internal.port = 19030;
    };

    # services.blockbook-frontend."NMC" = mkIf cfg.namecoin {
    #   enable = true;
    #   coinName = "Namecoin";
    #   listen.port = 9139;
    #   internal.port = 9039;
    #   rpc = {
    #     port = 8039;
    #   };
    #   extraConfig = {
    #     coin_label = "Namecoin";
    #     alternative_estimate_fee = "whatthefee-disabled";
    #     alternative_estimate_fee_params = "{\"url\": \"https://whatthefee.io/data.json\", \"periodSeconds\": 60}";
    #     fiat_rates = "coingecko";
    #     fiat_rates_params = "{\"url\": \"https://api.coingecko.com/api/v3\", \"coin\": \"nmc\", \"periodSeconds\": 60}";
    #   };
    # };

  };

  meta.maintainers = with maintainers; [ maintainers."1000101" ];

}
