(* Copyright Robur, 2020 *)

open Mirage

let ipv4 =
  let doc = Key.Arg.info ~doc:"IPv4 address" ["ipv4"] in
  Key.(create "ipv4" Arg.(required ipv4 doc))

let ipv4_gateway =
  let doc = Key.Arg.info ~doc:"IPv4 gateway" ["ipv4-gateway"] in
  Key.(create "ipv4-gateway" Arg.(required ipv4_address doc))

let upstream_resolver =
  let doc = Key.Arg.info ~doc:"Upstream DNS resolver IP" ["dns-upstream"] in
  Key.(create "dns-upstream" Arg.(opt (some ipv4_address) None doc))

let dnsvizor =
  let pin = "git+https://github.com/mirage/ocaml-dns.git" in
  let packages =
    [
      package "logs" ;
      package "metrics" ;
      package ~pin ~sublibs:["mirage"] "dns-stub";
      package ~pin "dns";
      package ~pin "dns-client";
      package ~pin "dns-mirage";
      package ~pin "dns-resolver";
      package ~pin "dns-tsig";
      package ~pin "dns-server";
      package "nocrypto";
      package "ethernet";
      package "arp-mirage";
      package ~sublibs:["ipv4"; "tcp"; "udp"; "icmpv4"] "tcpip"
    ]
  in
  foreign
    ~keys:[Key.abstract ipv4; Key.abstract ipv4_gateway; Key.abstract upstream_resolver]
    ~deps:[abstract nocrypto] (* initialize rng *)
    ~packages
    "Unikernel.Main"
    (random @-> pclock @-> mclock @-> time @-> network @-> job)

let () =
  register "dnsvizor" [
    dnsvizor $ default_random $ default_posix_clock
    $ default_monotonic_clock $ default_time
    $ default_network ]
