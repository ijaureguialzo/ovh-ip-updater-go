package main

import (
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/bugsnag/bugsnag-go"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}
	bugsnagApiKey := os.Getenv("BUGSNAG_API_KEY")
	bugsnag.Configure(bugsnag.Configuration{
		APIKey: bugsnagApiKey,
	})

	domainName := os.Getenv("DOMAIN_NAME")
	username := os.Getenv("OVH_USERNAME")
	password := os.Getenv("OVH_PASSWORD")

	ipAddress := ""
	prevIpAddress := ""

	for {
		prevIpAddress = ipAddress

		ipAddress, err = getIpAddress()
		if err != nil {
			bugsnag.Notify(err)
		} else if prevIpAddress != ipAddress {
			setDyndnsIpAddress(ipAddress, domainName, username, password)
		} else {
			log.Println("IP address is the same, skipping OVH set")
		}
		time.Sleep(1 * time.Hour)
	}

}

func getIpAddress() (string, error) {
	resp, err := http.Get("https://api.ipify.org")
	if err != nil {
		return "", errors.New("Unable to get IP Address")
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", errors.New("Unable to read api.ipify.org body")
	}
	return string(body), nil
}

func setDyndnsIpAddress(ipAddress string, domainName string, username string, password string) {
	client := &http.Client{}
	url := fmt.Sprintf("https://www.ovh.com/nic/update?system=dyndns&hostname=%s&myip=%s", domainName, ipAddress)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		bugsnag.Notify(err)
	}
	req.SetBasicAuth(username, password)

	resp, err := client.Do(req)
	if err != nil {
		bugsnag.Notify(err)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		bugsnag.Notify(err)
	}
	log.Println(string(body))
}