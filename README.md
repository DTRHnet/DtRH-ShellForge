
# **ShellForge**

**ShellForge** is a powerful, modular framework built to simplify and supercharge your POSIX-compliant shell scripting. It’s all about flexibility—dynamically integrating modules, managing commands effortlessly, and ensuring state persistence so your environment is always ready to go. Whether you're building something lightweight or crafting a complex scripting ecosystem, ShellForge gives you the tools to do it cleanly, efficiently, and with complete control. It’s practical, portable, and designed to make your workflows as seamless as they should be by balancing functionality with extensive environment compatibility.

---

## **Features**

1. **POSIX-Compliant**:
   - Fully adheres to POSIX standards for maximum compatibility across diverse environments, including `dash`, `bash`, and `sh`.

2. **Modular Design**:
   - Load, unload, and list modules dynamically with ease.
   - Extend your shell environment with reusable `.sfmod` modules for specific tasks.

3. **Command Registration**:
   - Dynamically register and deregister commands at any time for better organization and collisions prevention.

4. **State Management**:
   - Save and load the shell environment's state, ensuring seamless restoration across sessions.
   - Manage custom state files for different configurations.

5. **Foundational Extensibility**:
   - A clean base for extending functionality, with all built-in operations handled through the `shellforge` command.
   - A simple template and shell script is all that is necessary to build shellforge modules

NOTE: While shellforge and its modules are offered as POSIX compliant, it is not necessary for modules or changes to follow these standards. **At this time, there is no built in method to identify if a module is or isn't in compliance.**

---

## **How It Works**

ShellForge operates as a **sourceable script**. This ensures that all commands, environment variables, and modules are accessible directly in the current shell session. Changes (such as adding or removing modules) will invoke updates to the shellforge state, as well as updating the environment and setting/unsetting changes. Shellforge tracks all these changes, while providing the logic and commands to manage it all as a **toolkit**.

### **Key Concepts**

- **Modules**:
  - Modules (`.sfmod` files) extend the base functionality by adding reusable commands and utilities.
  - Modules dynamically register their commands into the global registry.

- **Global Registry**:
  - Tracks all registered commands and associates them with their parent modules.
  - Prevents duplicate command registration.

- **State Management**:
  - Captures the current environment (loaded modules and command registry) and saves it to a state file for reuse.

---

## **Installation**

Clone the repository and source the `shellforge.sh` script into your shell environment:
```sh
git clone https://github.com/DTRHnet/ShellForge.git
cd ShellForge
. ./shellforge.sh
```

---

## **Usage**

ShellForge introduces a single primary command: `shellforge`. This command uses a hierarchical structure with subcommands for managing modules, commands, states, and the environment.

### **Subcommands**

1. **Module Management**:
   - Load, unload, and list modules:
     ```sh
     shellforge module load <module_file>    # Load a module
     shellforge module unload <module_name>  # Unload a module
     shellforge module list                  # List all loaded modules
     ```

2. **Command Management**:
   - List all registered commands:
     ```sh
     shellforge command list
     ```

3. **State Management**:
   - Save, load, or display state information:
     ```sh
     shellforge state save [statefile]      # Save the current state file (default: module_state.env)
     shellforge state load [statefile]      # Load a saved state file
     shellforge state info                  # View current state file information
     ```

4. **Environment Information**:
   - Display environment-related variables:
     ```sh
     shellforge env info
     ```
---

## **Example Output**

### **Listing Modules**
```sh
$ shellforge module list

> [  Loaded Modules  ]

  Module Name          Summary                                           
--------------------------------------
  Textlib-Color        Records warnings for invalid inputs               


> [  Found Modules  ]

  Module Name                                                     
------------------------
./modules/text.sfmod
./modules/logger.sfmod
```

### **Loading a Module**
```sh
$ shellforge module load modules/logger.sfmod
Module 'Logger' (v1.0.0) by admin@dtrh.net loaded successfully!
```

### **Listing Registered Commands**
```sh
$ shellforge command list

> [ Registered Commands }

  Command Name         Module               Summary                                           
------------------------------------------------------------------
  logCreate            Logger               Create a new log file
  logWrite             Logger               Write a message to the log
  log_color_warning    Textlib-Color        Records warnings for invalid inputs               
  c2hex                Textlib-Color        Convert a named color to its hex color code       
  c2dec                Textlib-Color        Convert named color to its decimal color code 
```


### **Saving the State**
```sh
$ shellforge state save
State saved to states/module_state.env
```

---

## **Future Enhancements**

1. **Enhanced Module Searching**:
   - Support for custom module paths and better validation of module integrity.

2. **Improved State Management**:
   - Allow state comparisons and merging for collaborative scripting environments.

3. **Advanced Command Execution**:
   - Add hooks and event-driven behaviors for module commands.

---

## **Limitations**

1. **POSIX Constraints**:
   - Lacks advanced features like arrays and associative mappings, relying instead on string parsing.

2. **Performance**:
   - Heavy use of external commands (e.g., `awk`, `grep`) may impact performance in constrained environments.

3. **Complexity**:
   - Requires careful adherence to naming conventions and modular design to maintain compatibility.

---

## **License**

ShellForge is open-source and distributed under the [MIT License](LICENSE).

---

## **Contributors**

- **KBS** (admin [at] dtrh [dot] net)  
  Creator and maintainer of ShellForge.

---

By adhering to best practices in shell scripting and addressing common challenges, ShellForge represents a significant leap forward in modularity, portability, and maintainability with respect to POSIX compliant shell scripting. 

**Forge it** - And take comfort in knowing the (official) modules will run in just about any terminal emulator.