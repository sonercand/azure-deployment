az policy definition create --name tagging-Policy --display-name "Deny Creationg of Resources without a tag" --description "This policy denies creation of resources that have no tags" --rules deny_resource_without_tag.json --mode indexed

