(* This module tracks state of drag-n-drop *)

type position = int * int

type 'draggable dragData = {
    position: position option;
    source: 'draggable option;
    target: 'draggable option;
}

type 'draggable dragState =
    | NotDragging
    | Dragging of 'draggable dragData

type 'draggable msg =
    | Start of 'draggable
    | End of position
    | Over of 'draggable
    | Move of position

type ('model, 'draggable) funcs = {
    get_dragstate: 'model -> 'draggable dragState;
    can_drag: 'model -> 'draggable -> 'draggable -> bool;
}

let update (funcs: ('model, 'draggable) funcs) model (msg:'a msg) =
    let dragState = funcs.get_dragstate model in
    match msg, dragState with
    | Start source, _ -> Dragging {
        position = None;
        source = Some source;
        target = None;
    }
    | End _, Dragging _ -> NotDragging
    | Over target, Dragging ({ source = Some source } as state) when (funcs.can_drag model source target) ->
        Dragging { state with target = Some target }
    | Move (x,y), Dragging state -> Dragging { state with position = Some (x,y) }
    | _ -> dragState
