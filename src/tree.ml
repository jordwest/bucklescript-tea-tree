type taskId = string
exception Infinite_recursion of taskId

type task = {
    id: taskId;
    parent_id: taskId option;
    title: string;
}

module ItemMap = Map.Make(String)

type tasks = task ItemMap.t

let getTaskById (taskId : taskId) (list : tasks) =
    Utils.find_opt ItemMap.find taskId list

(* Generates a bunch of items and place them randomly in the tree *)
let rec add_random_children start_id end_id tasks =
    let id = string_of_int start_id in
    let parent_id =
        match start_id with
        | 0 -> None
        | other -> Some (string_of_int (Random.int other)) in
    let title = "Item " ^ id in
    let tasks = ItemMap.add id { id; parent_id; title } tasks in
    match start_id >= end_id with
    | true  -> tasks
    | false  -> add_random_children (start_id + 1) end_id tasks

let sample_tasks () =
    ItemMap.empty
        |> ItemMap.add "a" { id = "a"; parent_id = None; title = "This is a task" }
        |> ItemMap.add "ab" { id = "ab"; parent_id = (Some "a"); title = "This is a second level task" }
        |> ItemMap.add "ac" { id = "ac"; parent_id = (Some "a"); title = "This is another second level task" }
        |> ItemMap.add "abd" { id = "abd"; parent_id = (Some "ab"); title = "This is another third level task" }
        |> ItemMap.add "acd" { id = "acd"; parent_id = (Some "ac"); title = "This is a third level task" }
        (* Add a bunch of random items *)
        |> add_random_children 0 40

module TaskIdSet = Set.Make(String)

type taskIdSet = TaskIdSet.t

let get_ids_to_root (id : taskId) (tasks : tasks) =
    let rec recurse set id =
        let task = ItemMap.find id tasks in
        match TaskIdSet.mem id set with
        | true  -> raise (Infinite_recursion id)
        | false  ->
            let nextSet = TaskIdSet.add id set in
            (match task.parent_id with
                | Some pId -> recurse nextSet pId
                | None  -> nextSet) in
    recurse TaskIdSet.empty id

(* Determine if a task has an infinitely recursive heirarchy *)
let has_infinite_recursion (id : taskId) (tasks : tasks) =
    try let _ = get_ids_to_root id tasks in false
    with | Infinite_recursion _ -> true

(* Change an item's parent_id *)
let update_parent tasks sourceId targetId =
    let existingTask = ItemMap.find sourceId tasks in
    let updatedTask = { existingTask with parent_id = (Some targetId) } in
    ItemMap.add sourceId updatedTask tasks

type childMap = {
    root: taskId list;
    nodes: taskId list ItemMap.t;}

(* Calculate a map of parent -> child *)
let calculate_children (tasks : tasks) =
    let appendRootChild childId map =
        { map with root = (List.append map.root [childId]) } in
    let appendChild childId parentId map =
        {
        map with
        nodes =
            (match Utils.find_opt ItemMap.find parentId map.nodes with
            | Some l ->
                ItemMap.add parentId (List.append l [childId]) map.nodes
            | None  -> ItemMap.add parentId [childId] map.nodes)
        } in
    let f key task childMap =
        match task.parent_id with
            | Some pId -> appendChild key pId childMap
            | None  -> appendRootChild key childMap in
    let empty = { root = []; nodes = ItemMap.empty } in
    ItemMap.fold f tasks empty
