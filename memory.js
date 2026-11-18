// tab-bot — memory.js
// ذاكرة محلية بسيطة في ملف JSON: بيانات المستخدم، المشاريع، الملاحظات،
// وعداد الاستخدام اليومي. لا ترسل هذه البيانات لأي مكان؛ تبقى على جهازك.
const fs = require("fs");
const path = require("path");

const MEMORY_PATH = path.join(__dirname, "data", "memory.json");

const DEFAULT_MEMORY = {
  user: {
    name: "الصادق",
    language: "ar-AR",
    notes: []
  },
  projects: [],
  usage: {
    date: null, // YYYY-MM-DD
    count: 0
  }
};

function loadMemory() {
  try {
    if (fs.existsSync(MEMORY_PATH)) {
      const raw = fs.readFileSync(MEMORY_PATH, "utf8");
      const parsed = JSON.parse(raw);
      return {
        ...DEFAULT_MEMORY,
        ...parsed,
        user: { ...DEFAULT_MEMORY.user, ...(parsed.user || {}) },
        usage: { ...DEFAULT_MEMORY.usage, ...(parsed.usage || {}) }
      };
    }
  } catch (err) {
    console.error("تعذر قراءة ملف الذاكرة، سأبدأ بذاكرة جديدة:", err.message);
  }
  return JSON.parse(JSON.stringify(DEFAULT_MEMORY));
}

function saveMemory(memory) {
  fs.mkdirSync(path.dirname(MEMORY_PATH), { recursive: true });
  fs.writeFileSync(MEMORY_PATH, JSON.stringify(memory, null, 2), "utf8");
}

function todayString() {
  return new Date().toISOString().slice(0, 10);
}

// عداد الاستخدام اليومي: يصفّر تلقائياً عند تغير اليوم.
function checkAndCountUsage(memory, limit) {
  const today = todayString();
  if (memory.usage.date !== today) {
    memory.usage = { date: today, count: 0 };
  }
  if (memory.usage.count >= limit) {
    return false; // وصل للحد
  }
  memory.usage.count += 1;
  saveMemory(memory);
  return true;
}

function addProject(memory, name, description) {
  const project = {
    id: Date.now(),
    name: name.trim(),
    description: (description || "").trim(),
    createdAt: new Date().toISOString(),
    status: "نشط"
  };
  memory.projects.push(project);
  saveMemory(memory);
  return project;
}

function listProjects(memory) {
  return memory.projects;
}

function addNote(memory, text) {
  const note = { text: text.trim(), createdAt: new Date().toISOString() };
  memory.user.notes.push(note);
  saveMemory(memory);
  return note;
}

module.exports = {
  MEMORY_PATH,
  loadMemory,
  saveMemory,
  checkAndCountUsage,
  addProject,
  listProjects,
  addNote,
  todayString
};
