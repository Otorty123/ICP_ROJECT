import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";  // Added the missing import

actor TaskManager {
    // Task structure
    type Task = {
        id: Nat;
        description: Text;
        completed: Bool;
        createdAt: Time.Time;
        completedAt: ?Time.Time;
    };

    private stable var nextId : Nat = 0;
    private var tasks = HashMap.HashMap<Nat, Task>(0, Nat.equal, Hash.hash);

    // Create a new task
    public shared func createTask(description : Text) : async Nat {
        let task : Task = {
            id = nextId;
            description = description;
            completed = false;
            createdAt = Time.now();
            completedAt = null;
        };
        
        tasks.put(nextId, task);
        nextId += 1;
        return nextId - 1;
    };

    // Mark a task as completed
    public shared func completeTask(id : Nat) : async Bool {
        switch (tasks.get(id)) {
            case (null) { return false; };
            case (?task) {
                let updatedTask : Task = {
                    id = task.id;
                    description = task.description;
                    completed = true;
                    createdAt = task.createdAt;
                    completedAt = ?Time.now();
                };
                tasks.put(id, updatedTask);
                return true;
            };
        };
    };

    // Get all tasks
    public query func getAllTasks() : async [Task] {
        let taskBuffer = Buffer.Buffer<Task>(0);
        for ((_, task) in tasks.entries()) {
            taskBuffer.add(task);
        };
        return Buffer.toArray(taskBuffer);
    };

    // Get task by id
    public query func getTask(id : Nat) : async ?Task {
        return tasks.get(id);
    };

    // Get completed tasks count
    public query func getCompletedTasksCount() : async Nat {
        var count = 0;
        for ((_, task) in tasks.entries()) {
            if (task.completed) { count += 1; };
        };
        return count;
    };

    // Delete a task
    public shared func deleteTask(id : Nat) : async Bool {
        switch (tasks.get(id)) {
            case (null) { return false; };
            case (?task) {
                tasks.delete(id);
                return true;
            };
        };
    };

    // Update task description
    public shared func updateTaskDescription(id : Nat, newDescription : Text) : async Bool {
        switch (tasks.get(id)) {
            case (null) { return false; };
            case (?task) {
                let updatedTask : Task = {
                    id = task.id;
                    description = newDescription;
                    completed = task.completed;
                    createdAt = task.createdAt;
                    completedAt = task.completedAt;
                };
                tasks.put(id, updatedTask);
                return true;
            };
        };
    };
};