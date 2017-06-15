open Data
open Tea.App
open Tea.Html

type loc = int * int

(* Recursively renders a single node and its children *)
let rec node taskId is_ghost (model : state) =
    let task = Utils.find_opt Tree.ItemMap.find taskId model.tasks in
    let children =
        let childIds = Utils.find_opt Tree.ItemMap.find taskId (model.childMap).nodes in
        let mapper id = node id is_ghost model in
            match childIds
            with
                | Some c -> ul [] (List.map mapper c)
                | None  -> ul [] [] in

    let className = if is_ghost then "drag-off" else
        match model.dragState with
            | Drag.Dragging { source = Some Task sourceId } when sourceId == taskId -> "drag-source"
            | Drag.Dragging { target = Some Task targetId } when targetId == taskId -> "drag-target"
            | _ -> "" in (* This task isn't directly a drag source or target, so inherit style from parent task *)

    let onDragStart taskId ev =
        (ev##stopPropagation) ();
        (ev##preventDefault) ();
        Some (MsgDrag (Drag.Start (Task taskId))) in

    let onDragOver taskId ev =
        (ev##stopPropagation) ();
        (match model.dragState with
        | NotDragging  -> None
        | Dragging _ -> Some (MsgDrag (Drag.Over (Task taskId)))) in

    let evKey =
        taskId ^
        match model.dragState with
        | Dragging { source = Some Task _ } -> "task"
        | _ -> "not-dragging" in

    match task with
    | Some t ->
        li
            [class' className;
            onCB "mousedown" evKey (onDragStart t.id);
            onCB "touchstart" evKey (onDragStart t.id);
            onCB "mouseover" evKey (onDragOver t.id)]
            [text t.title; children]
    | None  -> li [] [text ("Task not found: " ^ taskId)]

let drag_ghost_view model =
    (* Attribute length must not change between updates. See vdom.ml in
     * bucklescript-tea.  *)
    let attrs visible x y = [ style "display" (if visible then "block" else "none")
                ; style "position" "absolute"
                ; style "pointer-events" "none"
                ; style "background-color" "#fff"
                ; style "padding" "5px"
                ; style "border" "3px solid black"
                ; x |> string_of_int |> style "left"
                ; y |> string_of_int |> style "top"
                ; style "width" "500"
    ] in
    match model.dragState with
        | Drag.Dragging { position = Some (x, y); source = Some Task sourceId } ->
            div (attrs true x y) [ ul [] [node sourceId true model] ]
        | _ -> div (attrs false 0 0) []

let view model =
  let mapper id = node id false model in
  div [] [
      Debug.debug_view model;
      drag_ghost_view model;
      ul [] (List.map mapper (model.childMap).root);
  ]

let subscriptions _ = let open Utils in
    Tea.Sub.batch
    [ subscribe_pageXY "mouseup" "mouseup" (fun (x,y) -> MouseUp (x, y))
    ; subscribe_pageXY "touchend" "touchend" (fun (x,y) -> MouseUp (x, y))
    ; subscribe_pageXY "mousemove" "mousemove" (fun (x,y) -> MouseMove (x, y))
    ]

let main =
  standardProgram
    { init
    ; update = update
    ; view
    ; subscriptions
    }

(* JS functions *)
external document : Web.Node.t = ""[@@bs.val ]
external getElementById : string -> Web.Node.t Js.null_undefined = ""
[@@bs.scope "document"][@@bs.val ]

(* Start everything *)
let _ = main (getElementById "app") ()
