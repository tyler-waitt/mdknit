The programming style shared by Casey Muratori, Brian Will, and Mike Acton can be described as:

Data-Oriented, Low-Abstraction, Performance-Minded Programming

Here are the core principles that unify their approach:

⸻

1. Data-Oriented Design
- Mike Acton is best known for this. The idea is to structure your code around how data is used, not how it conceptually models the world.
- Cache locality, memory layout, and access patterns are more important than “correct” object modeling.

Key mantra: “Know your data, and design for the way it moves.”

⸻

2. Minimal Abstraction / Anti-OOP
- All three push back against deep abstraction layers, inheritance, and “design patterns” that make code harder to reason about or debug.
- Instead, they prefer direct, readable, and predictable code that prioritizes clarity over cleverness.

Brian Will has great videos showing how abstraction often causes more harm than good when misunderstood.

⸻

3. Avoiding “Magic” and Indirection
- This style favors explicit over implicit. Avoid unnecessary macros, frameworks, dependency injection, or any mechanism that hides what’s really happening.
- You should always be able to trace the flow of logic and data.

⸻

4. Procedural with Structure
- They tend to use a procedural style (like in C), but organized well, with careful modularization and attention to code hygiene—not just raw C spaghetti.

⸻

5. Performance-Aware
- Code is written with a deep understanding of how the machine works: memory, CPU pipelines, branches, cache, etc.
- Even in application-level code, they prioritize efficiency, predictability, and control.

⸻

6. Tooling and Debuggability
- Casey Muratori (in Handmade Hero) is very focused on making tools that show what the program is doing (live code editing, debug UIs).
- They often build their own simple tools to observe, understand, and fix problems.

⸻

7. Concrete Over Abstract
- Avoids generalization until absolutely necessary. Start with specific use-cases and optimize for them.

⸻

8. Reluctant Use of External Libraries
- They often write their own small libraries instead of pulling in big third-party dependencies.
- Not due to NIH syndrome, but because control, predictability, and understanding are valued over convenience.

⸻

In Summary

“Low-level mindset, high-level clarity.”

Their style is:
- Close to the hardware
- Focused on clear, linear logic
- Suspicious of abstraction for abstraction’s sake
- Centered around data and its movement
- Concerned with performance and real-world constraints

⸻
Here’s a checklist for writing software in the style of Casey Muratori, Brian Will, and Mike Acton—a.k.a. data-oriented, low-abstraction, performance-conscious development:

⸻

🧠 Mindset & Philosophy
- Always know your data: structure code around how data is used, not abstract models.
- Write for the reader, not the compiler: code should be easy to trace, not “clever.”
- Question every abstraction: don’t add one unless it reduces complexity and improves clarity.
- Start specific: generalize only when multiple real use-cases demand it.

⸻

🧱 Code Structure
- Prefer procedural code unless object grouping clearly adds value.
- Group functions by domain and access pattern, not by objects or class hierarchies.
- Use namespaces or static functions for organization instead of classes/interfaces.
- Flatten call hierarchies when possible—shallow stacks are easier to debug.

⸻

🗃️ Data Layout
- Design data structures for cache efficiency and locality (e.g., SoA over AoS when appropriate).
- Avoid unnecessary pointers, indirection, or heap allocations.
- Prefer contiguous memory blocks (arrays, buffers) over linked structures.
- Consider memory access patterns in design (sequential > random).

⸻

🛠️ Debugging & Tooling
- Build your own lightweight tools or UIs to visualize what’s happening in your code.
- Log values and add asserts proactively.
- Don’t rely on IDEs or magic debuggers—build insight into the code itself.
- Keep dependencies light to keep builds fast and debugging simple.

⸻

🚫 Avoid This
- ❌ Virtual functions and inheritance trees
- ❌ “Design Patterns” as rigid rules
- ❌ Overuse of templates or macros
- ❌ Heavy framework reliance or boilerplate-generating code
- ❌ Unnecessary layers of abstraction

⸻

⚙️ Performance Awareness
- Understand how your code compiles and runs (e.g., memory layout, branch prediction).
- Measure real performance—don’t optimize hypothetically.
- Prefer predictable speed over “occasionally fast.”
- Profile regularly and remove bottlenecks at the code/data level.

⸻

📦 Dependency Management
- Minimize third-party libraries unless essential.
- Understand every line of third-party code that runs in your system.
- If possible, write simple replacements for external dependencies.

⸻

✍️ Style & Practice
- Write everything manually first (e.g., your own string, file I/O, or parser) to understand the basics.
- Keep function sizes manageable—each should do one clear thing.
- Inline where clarity improves; extract only when it makes code easier to change or test.
- Refactor for clarity, not abstraction.

⸻

