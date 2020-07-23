package example.terraform.tags


default pass = false

pass = true {
    count(violations) == 0
}

violations[addr] = msg {
    # r := missing_tag_owner[_]
    # m := {"address": r.address, "msg": "missing tag 'Owner'"}
    some addr
    tags := missing_tags[addr]
    count(tags) > 0
    msg := sprintf("missing tags '%s'", [concat("', '", tags)])
}

required_tag := {"Service", "Owner", "Environment"}

# violations[r.address] {
#     r := missing_tag_env[_]
# }

# violations[r.address] {
#     r := missing_tag_service[_]
# }

taggable := [
    "aws_s3_bucket",
    "aws_instance",
    "..."
]

change_to_taggable[r] {
    r := input.resource_changes[_]
    r.change.actions[_] == data.example.terraform.update_actions[_]
    r.type == taggable[_]
}

# missing_tag_owner[r] {
#     r := change_to_taggable[_]
#     not r.change.after.tags.Owner
# }

# missing_tag_env[r] {
#     r := change_to_taggable[_]
#     not r.change.after.tags.Environment
# }

# missing_tag_service[r] {
#     r := change_to_taggable[_]
#     not r.change.after.tags.Service
# }


missing_tags[r.address] = tags {
    r := change_to_taggable[_]
    tags := [tag | some tag
                    required_tag[tag]                       # for all required tags
                    resource_tags := r.change.after.tags    # all tags on the resource
                    not resource_tags[tag]]                 # change list does not contain that tag
}
