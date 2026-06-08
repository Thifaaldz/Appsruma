package models

import (
	"database/sql/driver"
	"encoding/json"
	"strings"
)

type StringList []string

func (list StringList) Value() (driver.Value, error) {
	if list == nil {
		return "[]", nil
	}
	value, err := json.Marshal([]string(list))
	if err != nil {
		return nil, err
	}
	return string(value), nil
}

func (list *StringList) Scan(value interface{}) error {
	if value == nil {
		*list = StringList{}
		return nil
	}

	var raw string
	switch typed := value.(type) {
	case []byte:
		raw = string(typed)
	case string:
		raw = typed
	default:
		*list = StringList{}
		return nil
	}

	raw = strings.TrimSpace(raw)
	if raw == "" || raw == "null" {
		*list = StringList{}
		return nil
	}

	var decoded []string
	if err := json.Unmarshal([]byte(raw), &decoded); err == nil {
		*list = StringList(decoded)
		return nil
	}

	*list = StringList{raw}
	return nil
}
