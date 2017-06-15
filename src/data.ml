
type draggable =
    | Task of Tree.taskId

type msg =
    | Init
    | MouseMove of int * int
    | MouseUp of int * int
    | MsgDrag of draggable Drag.msg

type state = {
    tasks: Tree.tasks;
    childMap: Tree.childMap;
    dragState: draggable Drag.dragState;
    lastAction: msg;
}

let get_dragstate model = model.dragState
let can_drag model source target =
    match source, target with
        | Task sId, Task tId when
            not (Tree.has_infinite_recursion sId (Tree.update_parent model.tasks sId tId))
                -> true
        | _ -> false

let drag_updater = Drag.update {get_dragstate; can_drag}

let init () =
    let tasks = Tree.sample_tasks () in
    ({
        tasks;
        childMap = (Tree.calculate_children tasks);
        dragState = NotDragging;
        lastAction = Init;
    }, Tea.Cmd.none)

let update_task_parent model sourceId targetId =
    let newTasks = Tree.update_parent model.tasks sourceId targetId in
    match Tree.has_infinite_recursion sourceId newTasks with
        | true -> model
        | false -> { model with
            tasks = newTasks;
            childMap = Tree.calculate_children newTasks;
        }


let update_drag model msg =
    match msg with
    | MsgDrag dragMsg ->
        ({ model with dragState = drag_updater model dragMsg }, Tea.Cmd.none)
    | _ -> (model, Tea.Cmd.none)

let set_last_action model msg =
    { model with lastAction = msg }

let rec update model (msg : msg) =
    let model = set_last_action model msg in
    match msg, model with
    | MsgDrag (Drag.End _), { dragState = Dragging { source = Some Task sId; target = Some Task tId }} ->
        update_drag (update_task_parent model sId tId) msg
    | MsgDrag _, _ -> update_drag model msg
    | MouseMove (x,y), { dragState = Dragging _ } -> update model (MsgDrag (Drag.Move (x,y)))
    | MouseUp (x,y), { dragState = Dragging _ } -> update model (MsgDrag (Drag.End (x,y)))
    | _, _ -> (model, Tea.Cmd.none)

let merge_commands a b = Tea.Cmd.batch [a; b]
