{ lib, ... }:
{
  options.cos = {
    username = lib.mkOption {
      type = lib.types.str;
    };
    hostName = lib.mkOption {
      type = lib.types.str;
    };
  };
}
