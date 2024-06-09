#!/bin/bash
# Author Name: Pankaj Mahanto
# Author Email: aryanpankaj78@gmail.com
# Social Media: https://www.linkedin.com/in/pankaj-mahanto78/
# © All rights reserved by pan78m - 2024

function head_banner() {
    clear
    # banner SMS
    echo "*******************************"
    echo "*                             *"
    echo "*     WELCOME TO MY           *"
    echo "*                             *"
    echo "*   STUDENT MANAGEMENT SYSTEM *"
    echo "*                             *"
    echo "*******************************"
    echo "Developed by Pankaj or '@pan78m' [All rights reserved]"
}

function return_function_value() {
    local INPUT="$1.csv"
    local id="$2"
    local field="$3"
    local result=0

    if [ ! -f "$INPUT" ]; then
        echo "$INPUT file not found"
        exit 1
    fi

    while IFS=',' read -r file_id name ex ex1; do
        if [ "$id" == "$file_id" ]; then
            case "$field" in
                1) result="$file_id" ;;
                2) result="$name" ;;
                3) result="$ex" ;;
                4) result="$ex1" ;;
            esac
            break
        fi
    done < "$INPUT"

    function_return_value="$result"
}

function create_semester() {
    echo "Enter the semester session(Spring/Fall):"
    read semester_session
    echo "Enter the semester year:"
    read semester_year
    semester="$semester_session-$semester_year"

    return_function_value semester "$semester" 1
    local create_semester_value_exists=$function_return_value

    if [ "$create_semester_value_exists" != "$semester" ]; then
        echo "$semester" >> semester.csv
        echo "$semester Semester created successfully. Semesters are:"
        cat -b semester.csv
    else
        echo "Semester already exists"
    fi
}

function create_user() {
    echo "Enter $1 id:"
    read user_id
    echo "Enter $1 name:"
    read user_name

    return_function_value "$1" "$user_id" 1
    local get_return_user_id=$function_return_value

    if [ "$get_return_user_id" != "$user_id" ]; then
        if [ "$1" == "teacher" ]; then
            echo "$user_id,$user_name" >> teacher.csv
        else 
            echo "$user_id,$user_name" >> student.csv 
        fi
        echo "$user_id $1 created successfully"
    else
        echo "$user_id already exists in $1 table"
    fi
}

function create_course() {
    echo "Enter course id:"
    read course_id
    echo "Enter course name:"
    read course_name
    echo "Enter teacher id:"
    read user_teacher_id
    echo "Enter semester (Spring-2023):"
    read create_course_semester

    return_function_value teacher "$user_teacher_id" 1
    local return_value_teacher=$function_return_value

    return_function_value semester "$create_course_semester" 1
    local return_value_semester=$function_return_value

    if [ "$return_value_teacher" != 0 ]; then
        if [ "$return_value_semester" != 0 ]; then
            echo "$course_id,$course_name,$create_course_semester,$user_teacher_id" >> course.csv
            echo "Course created successfully"
            view_courses
        else
            echo "Semester doesn't exist"
            exit 1
        fi
    else
        echo "Teacher doesn't exist"
        exit 1
    fi
}

function modify_teacher() {
    echo "==== Modify Courses Teacher ===="
    echo "Enter course id:"
    read user_course_id
    echo "Enter semester (Spring-2023):"
    read user_semester
    echo "Enter new teacher id:"
    read user_new_teacher_id

    return_function_value teacher "$user_new_teacher_id" 1
    local return_value_teacher=$function_return_value

    if [ "$return_value_teacher" != 0 ]; then
        if [ ! -f course.csv ]; then
            echo "course.csv file not found"
            exit 1
        fi

        while IFS=',' read -r course_id course_name semester teacher_id; do
            if [ "$course_id" == "$user_course_id" ] && [ "$user_semester" == "$semester" ]; then
                echo "$course_id,$course_name,$semester,$user_new_teacher_id" >> temp_course.csv
            else
                echo "$course_id,$course_name,$semester,$teacher_id" >> temp_course.csv
            fi
        done < course.csv

        mv temp_course.csv course.csv
        echo "Teacher successfully modified"
        view_courses
    else
        echo "Teacher doesn't exist"
    fi
}

function delete_student() {
    cat -b student.csv

    echo "Enter student id:"
    read user_delete_student_id

    return_function_value student "$user_delete_student_id" 1
    local return_value_delete_student=$function_return_value

    if [ "$return_value_delete_student" != 0 ]; then
        if [ ! -f student.csv ]; then
            echo "student.csv file not found"
            exit 1
        fi

        while IFS=',' read -r student_id student_name; do
            if [ "$user_delete_student_id" != "$student_id" ]; then
                echo "$student_id,$student_name" >> tempDeleteStudent.csv
            fi
        done < student.csv

        mv tempDeleteStudent.csv student.csv
        echo "Student successfully deleted"
    else
        echo "Student does not exist"
        exit 1
    fi
}

function return_course_count() {
    local course_id="$1"
    local count=0

    if [ ! -f courseEnroll.csv ]; then
        echo "courseEnroll.csv file not found"
        exit 1
    fi

    while IFS=',' read -r en_course_id student_id semester attendance quiz mid final; do
        if [ "$en_course_id" == "$course_id" ]; then
            count=$((count + 1))
        fi
    done < courseEnroll.csv

    return $count
}

function view_courses() {
    echo -e "=============================================  View Courses =============================================\n"
    echo -e "Sl: ID\t\tName\t\t\tSemester\tTeacher Id\tTeacher Name\t\tEnrolled Students\n"

    if [ ! -f course.csv ]; then
        echo "course.csv file not found"
        exit 1
    fi

    local count=0
    while IFS=',' read -r course_id course_name semester teacher_id; do
        count=$((count + 1))
        return_function_value teacher "$teacher_id" 2
        local teacher_name=$function_return_value

        return_course_count "$course_id"
        local course_count=$?

        echo -e "$count: $course_id\t$course_name\t$semester\t$teacher_id\t\t$teacher_name\t\t$course_count"
    done < course.csv
}

function enroll_course() {
    echo "Enter course id:"
    read user_course_id
    echo "Enter student id:"
    read user_student_id
    echo "Enter semester (Spring-2023):"
    read user_semester

    return_function_value semester "$user_semester" 1
    local semester_exists=$function_return_value

    return_function_value student "$user_student_id" 1
    local student_exists=$function_return_value

    return_function_value course "$user_course_id" 1
    local course_exists=$function_return_value

    if [ "$semester_exists" == 0 ] || [ "$student_exists" == 0 ] || [ "$course_exists" == 0 ]; then
        echo "Semester, Student, or Course may not exist."
        exit 1
    else
        echo "$user_course_id,$user_student_id,$user_semester,0,0,0,0" >> courseEnroll.csv
        echo "Student successfully enrolled into the course"
    fi
}

function view_course_enrollments() {
    echo "====================== View Student Course Enrollment ======================"
    echo -e "Sl: SID      SName                       Semester         Course Name\n"

    if [ ! -f courseEnroll.csv ]; then
        echo "courseEnroll.csv file not found"
        exit 1
    fi

    local count=0
    while IFS=',' read -r course_id student_id semester attendance quiz midterm final; do
        count=$((count + 1))
        return_function_value course "$course_id" 2
        local course_name=$function_return_value
        return_function_value student "$student_id" 2
        local student_name=$function_return_value

        echo -e "$count: $student_id   $student_name\t$semester   $course_name"
    done < courseEnroll.csv
}

function teacher_course_enrolled_students() {
    local teacher_id="$1"

    echo -e "Sl: CID\tCourse Name\tStudent Id\tStudent Name\tSemester\tAttendance\tQuiz\tMid\tFinal\n"

    if [ ! -f courseEnroll.csv ]; then
        echo "courseEnroll.csv file not found"
        exit 1
    fi

    local count=0
    while IFS=',' read -r course_id student_id semester attendance quiz midterm final; do
        return_function_value course "$course_id" 4
        local return_teacher_id=$function_return_value

        if [ "$return_teacher_id" == "$teacher_id" ]; then
            count=$((count + 1))
            return_function_value student "$student_id" 2
            local student_name=$function_return_value
            return_function_value course "$course_id" 2
            local course_name=$function_return_value

            echo -e "$count: $course_id\t$course_name\t$student_id\t$student_name\t$semester\t$attendance\t$quiz\t$midterm\t$final"
        fi
    done < courseEnroll.csv
}

function teacher_course_students_marks() {
    local teacher_id="$1"

    echo "Enter course id:"
    read user_course_id
    echo "Enter semester (Spring-2023):"
    read user_semester
    echo "Enter student id:"
    read user_student_id

    return_function_value course "$user_course_id" 4
    local return_teacher_id=$function_return_value

    if [ "$return_teacher_id" == "$teacher_id" ]; then
        if [ ! -f courseEnroll.csv ]; then
            echo "courseEnroll.csv file not found"
            exit 1
        fi

        while IFS=',' read -r course_id student_id semester attendance quiz midterm final; do
            if [ "$course_id" == "$user_course_id" ] && [ "$semester" == "$user_semester" ] && [ "$student_id" == "$user_student_id" ]; then
                echo "Attendance marks: "
                read attendance
                echo "Quiz marks: "
                read quiz
                echo "Midterm marks: "
                read midterm
                echo "Final marks: "
                read final

                echo "$course_id,$student_id,$semester,$attendance,$quiz,$midterm,$final" >> tempCourseEnroll.csv
            else
                echo "$course_id,$student_id,$semester,$attendance,$quiz,$midterm,$final" >> tempCourseEnroll.csv
            fi
        done < courseEnroll.csv

        mv tempCourseEnroll.csv courseEnroll.csv
        echo "Marks updated successfully"
    else
        echo "Teacher ID doesn't match the course"
    fi
}

function view_single_student() {
    local student_id="$1"

    echo "================ View Single Student ==================="
    echo -e "Sl: CID\tCourse Name\tSemester\tAttendance\tQuiz\tMidterm\tFinal\n"

    if [ ! -f courseEnroll.csv ]; then
        echo "courseEnroll.csv file not found"
        exit 1
    fi

    local count=0
    while IFS=',' read -r course_id enrolled_student_id semester attendance quiz midterm final; do
        if [ "$student_id" == "$enrolled_student_id" ]; then
            count=$((count + 1))
            return_function_value course "$course_id" 2
            local course_name=$function_return_value

            echo -e "$count: $course_id\t$course_name\t$semester\t$attendance\t$quiz\t$midterm\t$final"
        fi
    done < courseEnroll.csv
}

# Main Menu
choice="y"
while [[ "$choice" == "y" || "$choice" == "Y" ]]
do
    head_banner

    echo -e "\n=========================================="
    echo -e "= \t\t\t\t\t ="
    echo -e "= 1.  Admin\t\t\t\t ="
    echo -e "= 2.  Teacher\t\t\t\t ="
    echo -e "= 3.  Student\t\t\t\t ="
    echo -e "= 4.  Exit\t\t\t\t ="
    echo -e "= \t\t\t\t\t ="
    echo -e "=========================================="
    echo "Please enter your choice:"
    
    read user_choice
    
    case "$user_choice" in
        1)
            echo "Enter admin password: "
            read -s admin_password

            if [ "$admin_password" != "pan78m" ]; then
                echo "Invalid password"
            else
                choice="y"
                while [[ "$choice" == "y" || "$choice" == "Y" ]]
                do
                    head_banner

                    echo -e "\n================== Admin Menu ==================="
                    echo -e "= \t\t\t\t\t\t="
                    echo -e "= 1.  Create Semester\t\t\t\t="
                    echo -e "= 2.  Create/Update/View Course\t\t\t="
                    echo -e "= 3.  Create Student\t\t\t\t="
                    echo -e "= 4.  Create Teacher\t\t\t\t="
                    echo -e "= 5.  Enroll Course\t\t\t\t="
                    echo -e "= 6.  View Enrollments\t\t\t\t="
                    echo -e "= 7.  Delete Student\t\t\t\t="
                    echo -e "= 8.  Exit\t\t\t\t\t="
                    echo -e "==============================================="
                    echo "Please enter your choice:"

                    read admin_choice

                    case "$admin_choice" in
                        1)
                            head_banner
                            create_semester
                            ;;
                        2)
                            echo "==== Create/Update/View Course ===="
                            echo -e "\t1. Create Course"
                            echo -e "\t2. Update Course Teacher"
                            echo -e "\t3. View Courses"
                            read course_choice
                            case "$course_choice" in
                                1) create_course ;;
                                2) modify_teacher ;;
                                3) view_courses ;;
                                *) echo "Invalid input" ;;
                            esac
                            ;;
                        3)
                            head_banner
                            create_user student
                            ;;
                        4)
                            head_banner
                            create_user teacher
                            ;;
                        5)
                            head_banner
                            enroll_course
                            ;;
                        6)
                            head_banner
                            view_course_enrollments
                            ;;
                        7)
                            head_banner
                            delete_student
                            ;;
                        8)
                            exit
                            ;;
                        *)
                            echo "Invalid input"
                            ;;
                    esac
                    # Ask user if they want to continue
                    echo -e "\nDo you want to continue [y/n]: "
                    read choice
                done
                echo "Exit from admin"
            fi
            ;;
        2)
            echo "Enter teacher id: "
            read teacher_id_for_teacher

            return_function_value teacher "$teacher_id_for_teacher" 2
            local teacher_exists=$function_return_value

            if [ "$teacher_exists" == 0 ]; then
                echo "Teacher not exist"
            else
                choice="y"
                while [[ "$choice" == "y" || "$choice" == "Y" ]]
                do
                    head_banner

                    echo -e "\n================= Teacher Menu ================="
                    echo -e "= \t\t\t\t\t\t="
                    echo -e "= 1.  View Enrolled Students\t\t\t="
                    echo -e "= 2.  Update Student Marks\t\t\t="
                    echo -e "= 3.  Exit\t\t\t\t\t="
                    echo -e "==============================================="
                    echo "Please enter your choice:"
                    
                    read teacher_choice
                    
                    case "$teacher_choice" in
                        1)
                            head_banner
                            echo "==== View Enrolled Students ===="
                            teacher_course_enrolled_students "$teacher_id_for_teacher"
                            ;;
                        2)
                            head_banner
                            echo "==== Update Student Marks ===="
                            teacher_course_students_marks "$teacher_id_for_teacher"
                            ;;
                        3)
                            exit
                            ;;
                        *)
                            echo "Invalid input"
                            ;;
                    esac
                    # Ask user if they want to continue
                    echo -e "\nDo you want to continue [y/n]: "
                    read choice
                done
                echo "Exit from teacher"
            fi
            ;;
        3)
            echo "Enter student id: "
            read student_id_for_student

            return_function_value student "$student_id_for_student" 2
            local student_exists=$function_return_value

            if [ "$student_exists" == 0 ]; then
                echo "Student not exist"
            else
                choice="y"
                while [[ "$choice" == "y" || "$choice" == "Y" ]]
                do
                    head_banner

                    echo -e "\n================== Student Menu ==================="
                    echo -e "= \t\t\t\t\t\t="
                    echo -e "= 1.  View Your Enrollments\t\t\t="
                    echo -e "= 2.  Exit\t\t\t\t\t="
                    echo -e "=================================================="
                    echo "Please enter your choice:"

                    read student_choice

                    case "$student_choice" in
                        1)
                            head_banner
                            echo "==== View Your Enrollments ===="
                            view_single_student "$student_id_for_student"
                            ;;
                        2)
                            exit
                            ;;
                        *)
                            echo "Invalid input"
                            ;;
                    esac
                    # Ask user if they want to continue
                    echo -e "\nDo you want to continue [y/n]: "
                    read choice
                done
                echo "Exit from student"
            fi
            ;;
        4)
            echo "Exit from program"
            exit 0
            ;;
        *)
            echo "Invalid input"
            ;;
    esac
    # Ask user if they want to continue
    echo -e "\nDo you want to continue [y/n]: "
    read choice
done
