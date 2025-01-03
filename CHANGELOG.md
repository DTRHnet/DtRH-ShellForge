### **CHANGELOG: From Textlib to ShellForge**

Below is a detailed summary of the changes and enhancements made during the transition from **Textlib** to **ShellForge**, highlighting all functional, structural, and conceptual improvements.

---

## **[v0.1.0] - Transition to ShellForge**
### **Major Changes**
1. **Renamed Project**:
   - The project was renamed from **Bashlib-Textlib** to **ShellForge** to better reflect its broader scope and modular design philosophy.
   - Bashlib was flawed as it did not really give notice to the uch wider scope of the project (bash, dash, sh, ash, ksh, etc)
   - The name now emphasizes its purpose as a framework for crafting POSIX-compliant shell scripting environments, beyond just text manipulation. 

2. **Reorganized Command Hierarchy**:
   - Introduced a structured command hierarchy with clear subcommands:
     - `module` (managing modules: load, unload, list).
     - `command` (listing registered commands).
     - `state` (managing state: save, load, info).
     - `env` (displaying environment-related variables).
   - This new structure simplifies usage, improves clarity, and provides a logical flow for all operations.

3. **Enhanced Modularity**:
   - Completely restructured the system to fully support modular design:
     - `.sfmod` modules now encapsulate specific functionality, commands, and metadata.
     - Commands dynamically register and deregister themselves in a **global registry** when modules are loaded and unloaded.
     - Fixed some bugs in logic for testing if modules are loaded, thus fixing duplicated entries in the register.

4. **Global Registry**:
   - Introduced `GLOBAL_REGISTRY` to track all registered commands, their associated modules, and their summaries.
   - Ensures a single source of truth for command and module management.

5. **State Management**:
   - Added the ability to **save** and **load** the environment state:
     - Current modules and commands can be saved to a state file for reuse.
     - A default state file (`module_state.env`) ensures seamless state restoration.
   - Introduced `shellforge state info` to display the current environment’s state.

---

### **New Features**
1. **Dynamic Command Registration**:
   - Commands from loaded modules are registered dynamically into `GLOBAL_REGISTRY`.
   - Supports summaries for commands, making `shellforge command list` more informative and user-friendly.

2. **Command Deregistration**:
   - Ensured that unloading a module removes its commands from the environment and prevents them from being accessible or causing conflicts.

3. **POSIX-Compliant File Searching**:
   - Added a `findMod()` function to search for `.sfmod` files in the `$(pwd)/modules` directory, ensuring compatibility with POSIX shells.

4. **Formatted Output**:
   - Implemented standardized pretty-printing functions for native output (not relying on modules):
   - Unified the display of registered commands and loaded modules with aligned, tabular formatting.

5. **Environment Variables Management**:
   - Introduced `shellforge env info` to display critical environment variables:
     - `GLOBAL_REGISTRY`, `LOADED_MODULES`, `STATE_FILE`.

---

### **Functional Enhancements**
1. **Improved Command Listing**:
   - `shellforge command list` now displays:
     - Command Name.
     - Associated Module.
     - Command Summary (e.g., usage or purpose).
   - Ensures better readability with a tabular format.

2. **Improved Module Listing**:
   - `shellforge module list` now displays:
     - Module Name.
     - Module Summary.

3. **Dynamic State Files**:
   - State-saving and loading now support custom filenames, allowing multiple configurations to coexist.

4. **Validation for Module Integrity**:
   - Modules are required to implement specific functions (`MOD_INFO` and `MOD_COMMANDS`).
   - Added checks to ensure modules comply with expected standards.

---

### **Bug Fixes**
1. **Command Residue on Module Unload**:
   - Fixed the issue where commands from unloaded modules remained accessible in the shell.
   - Commands are now fully removed from the environment when the module is unloaded.

2. **Environment Persistence**:
   - Resolved issues with environment variables (`GLOBAL_REGISTRY` and `LOADED_MODULES`) not persisting correctly between sessions.
   - Properly exports and restores these variables during state saving and loading.

3. **File Extension Parsing**:
   - Improved handling of file extensions for modules and scripts using POSIX-compliant parameter expansion (`.${0##*.}`).

4. **Error Handling**:
   - Standardized error messages across all commands and subcommands.
   - Improved handling of missing or invalid modules during `module load`.

5. **Inconsistent Behavior with Sourced Scripts**:
   - Added a robust check to ensure `shellforge.sh` must be sourced, not executed directly.
   - Displays a clear error message and exits gracefully if executed directly.

---

### **Usability Enhancements**
1. **Multiline Banner Support**:
   - Added a `displayBanner()` function to print a visually appealing, multiline banner for ShellForge.
   - Allows customization for branding and informational messages.

2. **Dynamic Help System**:
   - Each command now includes a summary and detailed usage help, accessible via standardized outputs.

3. **Improved Script Organization**:
   - Refactored core functionality into distinct, reusable functions:
     - `load_module`, `unload_module`, `list_modules`.
     - `list_commands`.
     - `save_state`, `load_state`.
     - `findMod`.

4. **Cleaner Usage Messages**:
   - Consolidated all usage information into hierarchical subcommands for better readability:
     ```sh
     shellforge module <load|unload|list>
     shellforge command <list>
     shellforge state <save|load|info>
     shellforge env <info>
     ```

---

### **Deprecated or Removed Features**
1. **Textlib-Specific Commands**:
   - Removed text-specific commands that were tied to the old "Textlib" name and focus.
   - Shifted the emphasis to extensibility through `.sfmod` modules.

2. **Hardcoded Logic**:
   - Eliminated hardcoded command and module logic, fully replacing it with dynamic registration and modularity.

---

### **Future Roadmap**

**Read the shellforge.sh sourcecode - It details things TODO**



KBS - **admin**[at]**dtrh**[dot]**net**