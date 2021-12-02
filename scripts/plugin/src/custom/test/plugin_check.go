package main

import (
	"fmt"
	. "github.com/hyperledger/fabric/core/handlers/endorsement/api"
	"plugin"
)

func main() {
	fmt.Println("hello world")
	plug, err := plugin.Open("/home/atri/workspace_hlf/annpurna/scripts/plugin/customPlugin.so")
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
		panic("Plugin has no 'Add(int)int' function")
	}
	// Uses the function to return results
	addition := addFunc()
	fmt.Printf("\nAddition is:%d", addition)
}
