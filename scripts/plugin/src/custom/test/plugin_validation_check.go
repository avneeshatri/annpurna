package main

import (
	"fmt"
	validation "github.com/hyperledger/fabric/core/handlers/validation/api"
	"plugin"
)

func main() {
	fmt.Println("Custom Validation Plugin Test")
	//plug, err := plugin.Open("/go/src/github.com/hyperledger/fabric/release/linux-amd64/bin/customPlugin.so")
	plug, err := plugin.Open("/home/atri/go/src/github.com/hyperledger/fabric/release/linux-amd64/bin/customValidationPlugin.so")
	if plug == nil {
		fmt.Println("Nil plugin loaded")
	}
	symbol, err := plug.Lookup("NewPluginFactory")
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(symbol)
	addFunc, ok := symbol.(func() validation.PluginFactory)
	if !ok {
		fmt.Printf("Function not found")
		panic("Plugin has no 'NewPluginFactory' function")
	}
	// Uses the function to return results
	fmt.Printf("Found function \n")
	addition := addFunc()
	fmt.Printf("\n Function is:%d \n", addition)
}
