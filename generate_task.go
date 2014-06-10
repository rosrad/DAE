package main

import (
	"bufio"
	"fmt"
	"github.com/robfig/config"
	"os"
	"path/filepath"
	"strings"
)

type Task struct {
	env     string
	tag     string
	list    string
	feature string
}

func ReadTasks(tastfile string) []Task {
	fid, err := os.Open(tastfile)
	if err != nil {
		fmt.Println("Can not open the task file, err: ", err)
	}
	defer fid.Close()

	scanner := bufio.NewScanner(fid)
	var tasks []Task
	for scanner.Scan() {
		fields := strings.Split(scanner.Text(), ";")
		tasks = append(tasks, Task{fields[0], fields[1], fields[2], fields[3]})
	}
	return tasks
}

func main() {

	ini := "./conf.base"
	inf, _ := config.Read(ini, config.ALTERNATIVE_COMMENT, config.ALTERNATIVE_SEPARATOR, false, true)
	// create new options
	base_data_dir, _ := inf.String("BASE", "tmp_data")
	base_target, _ := inf.String("BASE", "target")
	base_source, _ := inf.String("BASE", "source")
	base_weight, _ := inf.String("BASE", "weight")
	default_weight, _ := inf.String("IN", "weight")
	base_feature, _ := inf.String("BASE", "feature_base")
	tasks := ReadTasks("task.list")
	for idx, task := range tasks {
		task_inf := config.New(config.ALTERNATIVE_COMMENT, config.ALTERNATIVE_SEPARATOR, false, true)
		task_inf.Merge(inf)
		task_inf.AddOption("IN", "tag", task.tag)
		task_inf.AddOption("IN", "feature_dir", filepath.Join(base_feature, task.feature))
		task_inf.AddOption("IN", "env", task.env)
		task_inf.AddOption("IN", "weight", base_weight+default_weight)
		task_inf.AddOption("IN", "data_dir", filepath.Join(base_data_dir, task.env, task.tag))
		task_inf.AddOption("IN", "list", filepath.Join(base_source+task.list))
		task_inf.AddOption("OUT", "dae_dir", filepath.Join(base_target, task.env, task.tag))
		task_inf.WriteFile(fmt.Sprintf("./conf.ini.%d", idx), 0666, "")
	}
}
