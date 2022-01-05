package main

import (
	"fmt"
	. "github.com/hyperledger/fabric/core/handlers/endorsement/api"
	"plugin"
)

func main1() {

	fmt.Println("hello world")
	plug, err := plugin.Open("/home/atri/workspace_hlf/annpurna/scripts/plugin/customPlugin.so")
	//plug, err := plugin.Open("/home/atri/go/src/github.com/hyperledger/fabric/release/linux-amd64/bin/customPlugin.so")
	if plug == nil {
		fmt.Println("Nil plugin loaded")
	}
	symbol, err := plug.Lookup("NewPluginFactory")
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(symbol)
	addFunc, ok := symbol.(func() PluginFactory)
	if !ok {
		fmt.Printf("Function not found")
		panic("Plugin has no 'Add(int)int' function")
	}
	// Uses the function to return results
	fmt.Printf("Found function \n")
	addition := addFunc()
	fmt.Printf("\n Function is:%d \n", addition)
}
