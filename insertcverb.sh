#!/bin/bash

# copy tikzpicture block inside cverbatim environment on top of each tikzpicture environment

done=`cat $1 | grep -n cverbatim | wc -l`
if ! (( done )); then
    echo "inserting..."
    i=1
    blkStop=0
    cp $1 texback
    touch temp
    for pos in `cat $1 | grep -n tikzpicture | awk -F: '{print $1}'`; do
      #  echo $pos
        i=$(( 1 - i ))
        if (( i )); then
            blkStop=$pos
            echo "\\begin{cverbatim}" >> temp
            sed -n "$blkStart, $blkStop p" $1 >> temp
            echo "\\end{cverbatim}" >> temp
            echo >> temp

            sed -n "$blkStart, $blkStop p" $1 >> temp
            echo >> temp

        else
            blkStart=$pos

            # insert things between tikz environment
            snippetStart=$(( blkStop + 1 ))
            snippetEnd=$(( blkStart - 1 ))
            if [ $snippetStart -le $snippetEnd ]; then
                j=0
                # find line-numbers of non-blank lines
                for lnum in `sed -n "$snippetStart, $snippetEnd p" $1 | grep -n '^[^ *$]' | awk -F: '{print $1}'`; do
                    if ! (( j )); then
                        j=1
                        newsnippetStart=$(( snippetStart + lnum - 1 ))
                    fi
                done

                # j eq 1 means there are non-blank lines, then need to insert relevant things
                if (( j )); then
                    newsnippetEnd=$(( snippetStart + lnum - 1 ))

                    echo "\\begin{cverbatim}" >> temp
                    sed -n "$newsnippetStart, $newsnippetEnd p" $1 >> temp
                    echo "\\end{cverbatim}" >> temp
                    echo >> temp

                    sed -n "$newsnippetStart, $newsnippetEnd p" $1 >> temp 
                    echo >> temp
                fi
            fi
        fi
    done
    cp temp $1
    ~/zrcommand/zrPdfLatex ./pgfDrawing.tex
    read -p "Are you sure to overwrite "$1"? [N/Y]: " OWRT
    case $OWRT in
        y | yes | Y | YES | Yes)
            echo "Updated :)" ;;
        *)
            cp texback $1
    esac
    rm -f temp texback
else
    echo "not fresh file, abort!"
fi
