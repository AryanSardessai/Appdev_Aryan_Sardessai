import { addDoc, collection, deleteDoc, doc, getDocs, orderBy, query, updateDoc } from "firebase/firestore";
import React, { useEffect, useState } from "react";
import { Alert, Button, FlatList, StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";
import { db } from "./firebaseConfig";

export default function Index() {
    const [task, setTask] = useState("");
    const [tasks, setTasks] = useState<any[]>([]);
    const [deletedTasks, setDeletedTasks] = useState<any[]>([]);

    // =======================================================================
    // 1. Fetching Functions
    // =======================================================================

    const fetchTasks = async () => {
        const snapshot = await getDocs(collection(db, "tasks"));
        setTasks(snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })));
    };

    const fetchDeletedTasks = async () => {
        const q = query(collection(db, "deletedTasks"), orderBy("deletedAt", "desc"));
        const snapshot = await getDocs(q);
        setDeletedTasks(snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })));
    };

    // =======================================================================
    // 2. CRUD Operations
    // =======================================================================

    const addTask = async () => {
        if (task.trim() === "") return;
        await addDoc(collection(db, "tasks"), {
            name: task,
            status: "pending",
            createdAt: new Date(),
        });
        setTask("");
        fetchTasks();
    };

    const toggleTask = async (id: string, current: string) => {
        await updateDoc(doc(db, "tasks", id), {
            status: current === "done" ? "pending" : "done",
        });
        fetchTasks();
    };

    const deleteTask = async (taskItem: any) => {
        await addDoc(collection(db, "deletedTasks"), {
            ...taskItem, 
            originalId: taskItem.id, 
            deletedAt: new Date(),   
        });
        await deleteDoc(doc(db, "tasks", taskItem.id));
        fetchTasks();
        fetchDeletedTasks();
    };

    // The most robust version of the Clear History function
    const clearHistory = () => {
        Alert.alert(
            "Clear History",
            "Are you sure you want to permanently delete all history?",
            [
                { text: "Cancel", style: "cancel" },
                { 
                    text: "Delete All", 
                    onPress: async () => {
                        try {
                            const snapshot = await getDocs(collection(db, "deletedTasks"));
                            
                            if (snapshot.docs.length === 0) {
                                console.log("History already empty. Skipping deletion.");
                                return;
                            }

                            console.log(`Found ${snapshot.docs.length} tasks to delete from history.`);

                            // Collect all the promises for deletion
                            const deletePromises = snapshot.docs.map(historyDoc => {
                                // IMPORTANT: Use .catch() to ensure Promise.all doesn't fail on a single error
                                return deleteDoc(doc(db, "deletedTasks", historyDoc.id)).catch(e => {
                                    console.error(`Failed to delete document ${historyDoc.id}:`, e);
                                    return null; 
                                });
                            });
                            
                            // Wait for ALL delete operations (successful or failed) to complete
                            await Promise.all(deletePromises);
                            
                            console.log("Batch delete operation complete. Refreshing list.");
                            
                            // Refresh the history list ONLY after all deletions are confirmed
                            fetchDeletedTasks();

                        } catch (error) {
                            console.error("Critical error during history clearance:", error);
                            Alert.alert("Critical Error", "Failed to clear history. Check console for details.");
                        }
                    }, 
                    style: "destructive" 
                },
            ]
        );
    };

    // =======================================================================
    // 3. Effects & UI
    // =======================================================================

    useEffect(() => {
        fetchTasks();
        fetchDeletedTasks();
    }, []);

    const renderTask = ({ item }: { item: any }) => (
        <View
            style={[
                styles.taskItem, 
                item.status === "done" ? styles.taskDone : styles.taskPending
            ]}
        >
            <TouchableOpacity
                onPress={() => toggleTask(item.id, item.status)}
                style={styles.taskTextContainer}
            >
                <Text style={styles.taskText}>
                    {item.name} ({item.status})
                </Text>
            </TouchableOpacity>

            <TouchableOpacity 
                onPress={() => deleteTask(item)}
                style={styles.deleteButton}
            >
                <Text style={styles.deleteButtonText}>🗑️</Text>
            </TouchableOpacity>
        </View>
    );

    const renderDeletedTask = ({ item }: { item: any }) => (
        <View style={styles.deletedTaskItem}>
            <Text style={styles.deletedTaskText}>
                {item.name} (Deleted)
            </Text>
            <Text style={styles.deletedTaskDate}>
                Deleted: {new Date(item.deletedAt.toDate()).toLocaleDateString()}
            </Text>
        </View>
    );

    return (
        <View style={styles.container}>
            <Text style={styles.title}>Active Tasks</Text>

            <View style={styles.inputContainer}>
                <TextInput
                    value={task}
                    onChangeText={setTask}
                    placeholder="Enter task"
                    placeholderTextColor="#888"
                    style={styles.textInput}
                />
                <Button title="Add" onPress={addTask} />
            </View>

            <FlatList
                data={tasks}
                keyExtractor={(item) => item.id}
                renderItem={renderTask}
                style={{marginBottom: 20}}
            />

            {/* History Section Header with Clear Button */}
            <View style={styles.historyHeader}>
                <Text style={styles.title}>Deleted History</Text>
                {deletedTasks.length > 0 && (
                    <Button 
                        title="Clear History" 
                        onPress={clearHistory} 
                        color="#FF6347" // Use a strong color for a destructive action
                    />
                )}
            </View>

            <FlatList
                data={deletedTasks}
                keyExtractor={(item) => item.id}
                renderItem={renderDeletedTask}
            />
        </View>
    );
}

// =======================================================================
// 4. Styling
// =======================================================================

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: "#111", padding: 20 },
    title: { color: "white", fontSize: 24, marginBottom: 10, marginTop: 10 },
    inputContainer: { flexDirection: "row", marginBottom: 20, alignItems: 'center' },
    textInput: {
        flex: 1,
        borderWidth: 1,
        borderColor: "#555",
        borderRadius: 8,
        padding: 10,
        color: "white",
        marginRight: 10
    },
    // New style for history header layout
    historyHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 10,
    },
    taskItem: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: 10,
        borderRadius: 8,
        marginBottom: 8,
    },
    taskTextContainer: { flex: 1, paddingRight: 10 },
    taskPending: { backgroundColor: "#222" },
    taskDone: { backgroundColor: "#226622" },
    taskText: { color: "white" },
    deleteButton: { padding: 5, borderRadius: 5, backgroundColor: '#444' },
    deleteButtonText: { color: '#fff', fontSize: 18 },
    deletedTaskItem: { padding: 10, backgroundColor: "#333", borderRadius: 8, marginBottom: 5 },
    deletedTaskText: { color: "#ccc", textDecorationLine: 'line-through', fontSize: 14 },
    deletedTaskDate: { color: "#888", fontSize: 10, marginTop: 4 }
});