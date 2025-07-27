NAME		= add_nums
SOURCE		= ${NAME}.asm


all: ${NAME}


# assemble
${NAME}.o:
	nasm -f elf64 ${SOURCE} -o ${NAME}.o


# link
${NAME}: ${NAME}.o
	ld ${NAME}.o -o ${NAME}


clean:
	rm -f ${NAME}.o


fclean: clean
	rm -f ${NAME}


re: clean all


.PHONY: all clean fclean re
