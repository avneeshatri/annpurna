/*
Copyright IBM Corp. All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"errors"
	"fmt"

	"github.com/hyperledger/fabric-protos-go/peer"
	. "github.com/hyperledger/fabric/core/handlers/endorsement/api"
	. "github.com/hyperledger/fabric/core/handlers/endorsement/api/identities"
)

// To build the plugin,
// run:
//    go build -buildmode=plugin -o escc.so plugin.go

// CustomEndorsementFactory returns an endorsement plugin factory which returns plugins
// that behave as the default endorsement system chaincode
type CustomEndorsementFactory struct {
}

// New returns an endorsement plugin that behaves as the default endorsement system chaincode
func (*CustomEndorsementFactory) New() Plugin {
	fmt.Println("Custom Plugin : New")
	return &CustomEndorsement{}
}

// CustomEndorsement is an endorsement plugin that behaves as the default endorsement system chaincode
type CustomEndorsement struct {
	SigningIdentityFetcher
}

// Endorse signs the given payload(ProposalResponsePayload bytes), and optionally mutates it.
// Returns:
// The Endorsement: A signature over the payload, and an identity that is used to verify the signature
// The payload that was given as input (could be modified within this function)
// Or error on failure
func (e *CustomEndorsement) Endorse(prpBytes []byte, sp *peer.SignedProposal) (*peer.Endorsement, []byte, error) {
	fmt.Println("Custom Plugin : Endorse")
	signer, err := e.SigningIdentityForRequest(sp)
	fmt.Println("Proposal signer")

	if err != nil {
		return nil, nil, fmt.Errorf("failed fetching signing identity: %v", err)
	}
	// serialize the signing identity
	identityBytes, err := signer.Serialize()
	fmt.Println("Endorser MSP:" + string(identityBytes))
	if err != nil {
		return nil, nil, fmt.Errorf("could not serialize the signing identity: %v", err)
	}

	// sign the concatenation of the proposal response and the serialized endorser identity with this endorser's key
	signature, err := signer.Sign(append(prpBytes, identityBytes...))
	if err != nil {
		return nil, nil, fmt.Errorf("could not sign the proposal response payload: %v", err)
	}
	endorsement := &peer.Endorsement{Signature: signature, Endorser: identityBytes}
	return endorsement, prpBytes, nil
}

// Init injects dependencies into the instance of the Plugin
func (e *CustomEndorsement) Init(dependencies ...Dependency) error {
	fmt.Println("Custom Plugin : Init")
	for _, dep := range dependencies {
		sIDFetcher, isSigningIdentityFetcher := dep.(SigningIdentityFetcher)
		if !isSigningIdentityFetcher {
			continue
		}
		e.SigningIdentityFetcher = sIDFetcher
		return nil
	}
	return errors.New("could not find SigningIdentityFetcher in dependencies")
}

// NewPluginFactory is the function ran by the plugin infrastructure to create an endorsement plugin factory.
func NewPluginFactory() PluginFactory {
	fmt.Println("Custom Plugin : NewPluginFactory")
	return &CustomEndorsementFactory{}
}

func main() {
	fmt.Println("custom plugin main")
}
