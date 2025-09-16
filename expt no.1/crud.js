// Initial array
let names = ["Alice", "Bob", "Charlie"];
console.log("Initial array:", names);

// -------------------------
// ✅ CREATE
// -------------------------

// Add to the end
names.push("David");

// Add to the beginning
names.unshift("Eve");

// Add at a specific index (e.g., index 2)
names.splice(2, 0, "Frank");

console.log("After CREATE operations:", names);

// -------------------------
// 🔍 READ
// -------------------------

// Read by index
console.log("Name at index 1:", names[1]);

// Read all using forEach
console.log("All names:");
names.forEach((name, index) => {
  console.log(`${index}: ${name}`);
});

// Find a name
let found = names.find(name => name === "Charlie");
console.log("Found name:", found);

// -------------------------
// ✏️ UPDATE
// -------------------------

// Update by index
names[0] = "Evelyn"; // Change "Eve" to "Evelyn"

// Update using findIndex
let indexToUpdate = names.findIndex(name => name === "Bob");
if (indexToUpdate !== -1) {
  names[indexToUpdate] = "Bobby";
}

console.log("After UPDATE operations:", names);

// -------------------------
// ❌ DELETE
// -------------------------

// Delete by index
names.splice(2, 1); // Remove 1 item at index 2

// Delete last item
names.pop();

// Delete first item
names.shift();

// Delete by value (e.g., remove "Charlie")
let indexToDelete = names.indexOf("Charlie");
if (indexToDelete !== -1) {
  names.splice(indexToDelete, 1);
}

console.log("After DELETE operations:", names);
 