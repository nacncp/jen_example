${join("\n", [
  "[web]",
  join("\n", [
    for index in range(zone) : <<EOF
${pub_name[index]} ansible_host=${pub_ip[index]} ansible_user=root ansible_password=${pub_passwd[index]}
EOF
  ]),
  "[was]",
  join("\n", [
    for index in range(zone) : <<EOF
${pri_name[index]} ansible_host=${pri_ip[index]} ansible_user=root ansible_password=${pri_passwd[index]}
EOF
  ])
])}
