#!/bin/sh

start_week=1
end_week=8
members=("건회" "종훈" "준호" "혜온")

week=$start_week
while [ $week -le $end_week ]
do
  week_folder="$week""주차"
  mkdir -p "$week_folder"

  for member in ${members[@]}
  do
     mkdir -p "$week_folder/$member"
     touch "$week_folder/$member/week$week.md"
  done

  week=$((week+1))
done