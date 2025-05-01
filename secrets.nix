let
  attr = builtins.listToAttrs (
    map (secretName: {
      name = "encrypt/${secretName}.age";
      value.publicKeys = secrets."${secretName}" ++ system.allen;
    }) (builtins.attrNames secrets)
  );
  system = {
    allen = [
      "age1yubikey1q20jh97qrk9kspzfmh4hrs8qgvuq34lvhm2pum9dae7p97gq78tsghyyha3"
      "age1yubikey1qf42tcrzealy89zpmat6c9fzza9pgt8f3nwl42pvj7sk7lllf623vmjq30d"
      "age1yubikey1q0kv8am08zj3pdakl8407xd8j0qxxytzwqx09vrtk64dsw2r5qragk5kd4f"
      "age1wjqegc62gpyvp4yfdqfk4vclfgdh3awlv03rgthcje398a860p7qpglp6w"
      "age1tp5ln7rhy9y0w7lgtamtgjn4w4sajlm36fj0le4smf3hf0hlf4ysq03uhh"
      "age1758tal2rl0ew693xt6l2ffwnrua33sxr6tc4ta3utu639ldfq53szvgm0g"
      "age1q5urgt9hszq2j9p2qtprl853w6gcy9wapzt73r73xmjla4zhq98scpl8rm"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQvZDcMvDnAAUqvyFGajabemVsOMC17jINp0fkMII0m"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9OkpTcjwWLH2fo8SUTVjb2NYEc6w996Cwr0wL2cRDx"
    ];
  };
  secrets = {
    # keep-sorted start
    env = [ ];
    # keep-sorted end
  };
in
attr
