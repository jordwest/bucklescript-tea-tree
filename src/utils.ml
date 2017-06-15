(* Converts an exceptional find function to one which returns an option
 * when something is not found. *)
let find_opt finder key map =
    try Some (finder key map)
    with Not_found -> None

(* This sets up and tears down a standard JS event handler *)
let subscribe key eventName (tagger : Web.Node.t Web_event.t -> 'a) =
    let open Vdom in
    (* Calling enableCall sets up event handlers, then returns a function
     * for removing the same event handlers. *)
    let enableCall callbacks =
        (* Set up a handler to transform *)
        let handler: Web.Node.event_cb =
            fun [@bs] _event  -> callbacks.enqueue (tagger _event) in
        (* Attach the handler *)
        let () = Web.Window.addEventListener eventName handler false in
        (* Return the cleanup function *)
        fun () -> Web.Window.removeEventListener eventName handler false in
    Tea_sub.registration key enableCall

let subscribe_pageXY key eventName (tagger : (int * int) -> 'a) =
    subscribe key eventName (fun ev -> tagger (ev##pageX, ev##pageY))
