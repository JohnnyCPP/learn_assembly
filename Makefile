NAME		= hello_world
SOURCE		= hello_world.asm


all: ${NAME}


# assemble
${NAME}.o:
	nasm -f elf64 ${SOURCE} -o ${NAME}.o


# link
#
# "-no-pie" disables Position-Independent Executables for simplicity
${NAME}: ${NAME}.o
	cc -no-pie ${NAME}.o -o ${NAME}


clean:
	rm -f ${NAME}.o


fclean: clean
	rm -f ${NAME}


re: clean all


.PHONY: all clean fclean re
