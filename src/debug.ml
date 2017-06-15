open Data
open Tea.Html

let coords_to_string (x, y) =
    (string_of_int x) ^ ", " ^ (string_of_int y)

let message_to_text (msg : msg) =
    match msg with
    | MsgDrag Drag.Start (Task taskId) -> "StartDrag " ^ taskId
    | MsgDrag Drag.End _ -> "EndDrag"
    | MsgDrag Drag.Over (Task taskId) -> "DragOver " ^ taskId
    | MsgDrag Drag.Move p -> "DragMove " ^ coords_to_string p
    | MouseMove (x, y) -> "MouseMove " ^ coords_to_string (x,y)
    | Init -> "Init"
    | _ -> "Unknown message"

let debug_view (model: state) =
    div [
        style "position" "fixed";
        style "top" "0";
        style "right" "0";
        style "border" "1px solid #aaa";
        style "padding" "5px";
        style "background-color" "#fff";
    ] [text (message_to_text model.lastAction)]
