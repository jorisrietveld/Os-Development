#																			#
# 	Author: Joris Rietveld <jorisrietveld@gmail.com>						#
#																			#
#	Description:															#
#	Make file for assembling, linking and running assembler programs.		#
#																			#
.DEFAULT_GOAL:=help
BASE_NAME:=hello1
WINDOW_WIDTH=67

all: .PRINT_HEADER assemble link run .PRINT_FOOTER

assemble: $(BASE_NAME).asm ## Assemle the code to binary instuctions.
	@echo "\e[34m║\e[39m Assebling..."
	@nasm -f elf64 -o $(BASE_NAME).o $(BASE_NAME).asm
	@echo "\e[34m║\e[39m \t\e[92mSuccessfully assembled $(BASE_NAME).asm to $(BASE_NAME).0\e[39m"

link: $(BASE_NAME).o ## Assemle the code to binary instuctions.
	@echo "\e[34m║\e[39m Assebling... \t\t\t\t\t\t\\t\t\t\t\t\t\t \e[34m║\e[39m "
	@ld -o $(BASE_NAME) $(BASE_NAME).o
	@echo "\e[34m║\e[39m \t\e[92mSuccessfully linked $(BASE_NAME).0 to $(BASE_NAME)\e[39m"

run: $(``BASE_NAME) ## Run the compiled binary.
	@echo "\e[34m║"
	@echo "\e[34m║\e[39m Exectuting the program:"
	@echo "\e[34m║"
	@./hello1 | (echo -n "\e[34m║\e[39m " && cat)

.PHONY: help

.PRINT_HEADER:
	@echo "\e[34m\e[1m\n"
	@echo "███████████████████████████████████████████████████████████████████"
	@echo "█████████████████████\e[44mx64 Assembler Tutorial\e[34m████████████████████████"
	@echo "║                                                                 ║"
	@echo "║       Assemble, Link and execute the $(BASE_NAME) program\t\t\t  ║"
	@echo "╟─────────────────────────────────────────────────────────────────╢"

.PRINT_FOOTER:
	@echo "\e[34m║"
	@echo "╚═════════════════════════════════════════════════════════════════╝\e[39m"
	@seq -s= 10|tr -d '[:digit:]'
	@echo "Hello world" | printf "\e[34m║\e[39m %-64s\e[34m║\e[39m"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'



