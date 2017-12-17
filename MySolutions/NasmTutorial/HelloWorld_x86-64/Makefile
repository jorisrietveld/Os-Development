#																			#
# 	Author: Joris Rietveld <jorisrietveld@gmail.com>						#
#																			#
#	Description:															#
#	Make file for assembling, linking and running assembler programs.		#
#																			#
.DEFAULT_GOAL:=help
BASE_NAME:=hello
WHITE_FG=\e[97m
GREEN_FG=\e[92m
BLUE_FG=\e[34m
BLUE_BG=\e[44m
BLACK_BG=\e[49m
BORDER=$(BLACK_BG)$(BLUE_FG)║$(WHITE_FG)
WINDOW_WIDTH=65
PRINT=printf "$(BORDER)%-$(WINDOW_WIDTH)s$(BORDER)\n"
PRINT_INFO=printf "$(BORDER)%-$(WINDOW_WIDTH)s$(BORDER)\n"
PRINT_SUCCESS=printf "$(BORDER)$(GREEN_FG)%-$(WINDOW_WIDTH)s$(BORDER)\n"
REPEAT=seq -s─ $(WINDOW_WIDTH)|tr -d '[:digit:]'
PRINT_BR=printf "$(BLUE_FG)╟─`$(REPEAT)`╢$(WHITE_FG)\n"

all: .PRINT_HEADER assemble link run .PRINT_FOOTER

assemble: $(BASE_NAME).asm ## Assemle the code to binary instuctions.
	@$(PRINT_INFO) " Assebling..."
	@nasm -f elf64 -o $(BASE_NAME).o $(BASE_NAME).asm
	@$(PRINT_SUCCESS) " Successfully assembled $(BASE_NAME).asm to $(BASE_NAME)."

link: $(BASE_NAME).o ## Assemle the code to binary instuctions.
	@$(PRINT_INFO) " Assebling..."
	@ld -o $(BASE_NAME) $(BASE_NAME).o
	@$(PRINT_SUCCESS) " Successfully linked $(BASE_NAME).0 to $(BASE_NAME)."

run: $(``BASE_NAME) ## Run the compiled binary.
	@$(PRINT_BR)
	@$(PRINT) " Exectuting the program:"
	@$(PRINT_BR)
	@printf "$(BORDER)%-$(WINDOW_WIDTH)s$(BORDER)\n" " "
	@./$(BASE_NAME) | (echo -n "$(BORDER) " && cat && echo -n "  \t\t  $(BORDER)")

.PHONY: help

.PRINT_HEADER:
	@echo "$(BLUE_FG)"
	@echo "███████████████████████████████████████████████████████████████████"
	@echo "█████████████████████$(BLUE_BG)$(WHITE_FG)x64 Assembler Tutorial$(BLUE_FG)$(BLACK_BG)████████████████████████"
	@$(PRINT) " Assemble, Link and execute the $(BASE_NAME) program"
	@$(PRINT_BR)

.PRINT_FOOTER:
	@echo "\n$(BLUE_FG)╚═════════════════════════════════════════════════════════════════╝$(WHITE)"


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'



