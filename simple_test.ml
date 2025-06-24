open Printf

let main () =
  printf "Starting simple test...\n"; flush_all ();
  let args = Sys.argv in
  printf "Arguments: %d\n" (Array.length args); flush_all ();
  for i = 0 to Array.length args - 1 do
    printf "  arg[%d] = %s\n" i args.(i); flush_all ()
  done;
  printf "Test complete!\n"; flush_all ()

let () = main ()
