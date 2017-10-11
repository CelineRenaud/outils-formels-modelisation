import TaskManagerLib
import Foundation

let  taskManager = createTaskManager()

// Show here an example of sequence that leads to the described problem.
// For instance:

   	let taskPool    = taskManager.places.first { $0.name == "taskPool" }!
        let processPool = taskManager.places.first { $0.name == "processPool" }!
        let inProgress  = taskManager.places.first { $0.name == "inProgress" }!

/*Dans ce cas le RDP ne peux pas fonctionné comme prévu. En effet, dans le cas ou deux processus sont produit dans processPool :les deux processus peuvent être consommés par exec sur la même tâche consécutivement. Le deuxième sera évaluer mais pas le premier qui sera traité comme fail alors qu'il ne l'est peut être pas. Le problème découle de l'ordre des transitions. Exemple qui ne marche pas : */


let create   = taskManager.transitions.first { $0.name == "create" }!
let spawn      = taskManager.transitions.first { $0.name == "spawn" }!
let exec        = taskManager.transitions.first { $0.name == "exec" }!
let success     = taskManager.transitions.first { $0.name == "success" }!
let fail        = taskManager.transitions.first { $0.name == "fail" }!


let m1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0])
let m2 = spawn.fire(from: m1!)
let m3 = spawn.fire(from: m2!)
let m4 = exec.fire(from: m3!)
let m5 = exec.fire(from: m4!)
let m6 = success.fire(from: m5!)

/*Pour corriger ce reseau, il est nécessaire d'établir un ordre des transition. Tout d'abord exec, puis l'évaluation par success ou fail.*/

let correctTaskManager = createCorrectTaskManager()

	let correctTaskPool    = correctTaskManager.places.first { $0.name == "taskPool" }!
        let correctProcessPool = correctTaskManager.places.first { $0.name == "processPool" }!
        let correctInProgress  = correctTaskManager.places.first { $0.name == "inProgress" }!
	let blocProcess = correctTaskManager.places.first { $0.name == "blocProcess" }!

/*Pour se faire on définit une place supplémentaire blocProcess avec un jetton dans le marquage de départ. Cette place est une précondition au fonctionnement de exec, et n'obtient qu'un jetton que lorsque le processus a été évalué (fail ou success).

Ce qui crée bien un ordre sur les transition (exec peut s'exécuter si et seulement si (fail ou success ont été exécutée)*/

let m11 = create.fire(from: [correctTaskPool: 0, correctProcessPool: 0, correctInProgress: 0, blocProcess : 1])
let m21 = spawn.fire(from: m11!)
let m31 = spawn.fire(from: m21!)
let m41 = exec.fire(from: m31!)
//let m5 = exec.fire(from: m4!) cette exécution est rendue impossible par blocProcess qui n'a pas de jetton
let m61 = success.fire(from: m41!)




