# update-snp.zsh: collect the snapshots of a project into a temp folder.
# Source it (e.g. from ~/.zshrc): a script cannot change the caller's directory.
#
#   update-snp ansible
#
# Leaves you in the temp folder ($SNP_TEMP) to upload the files to the project.
# Return with `cd $SNP_BEFORE` or `cd -`.

SNP_BASE=${SNP_BASE:-$HOME/dev/codeberg.org/neox5}

# project -> list of "<repo dir>[:<snapshot name>]"
# Snapshot file is <SNP_BASE>/<repo dir>/<snapshot name>.snp
# (default snapshot name: <repo dir>); it is copied under the same name.
typeset -gA SNP_PROJECTS
SNP_PROJECTS[ansible]="
  ansible-collection-platform
  ansible-collection-overlay
  ansible-site-starter
  ssh-public-keys-starter
  ansible:ansible-ref
"

update-snp() {
  local project=$1
  if [[ -z $project || -z ${SNP_PROJECTS[$project]-} ]]; then
    print -u2 "usage: update-snp <project>   projects: ${(kj:, :)SNP_PROJECTS}"
    return 1
  fi

  local -a items=(${=SNP_PROJECTS[$project]})
  local entry dir name src missing=0
  for entry in $items; do
    dir=${entry%%:*}
    name=${entry#*:}
    src=$SNP_BASE/$dir/$name.snp
    [[ -f $src ]] || { print -u2 "missing: $src"; missing=1 }
  done
  (( missing )) && return 1

  export SNP_BEFORE=$PWD
  export SNP_TEMP=$(mktemp -d)

  local repo_ts snp_ts
  for entry in $items; do
    dir=${entry%%:*}
    name=${entry#*:}
    src=$SNP_BASE/$dir/$name.snp
    cp -- $src $SNP_TEMP/$name.snp
    print -r -- "$name.snp  $(head -n 1 $src)"
    repo_ts=$(git -C $SNP_BASE/$dir log -1 --format=%ct 2>/dev/null)
    snp_ts=$(date -r $src +%s)
    if [[ -n $repo_ts ]] && (( repo_ts > snp_ts )); then
      print -u2 "  warning: $dir has a commit newer than its snapshot"
    fi
    if [[ -n $(git -C $SNP_BASE/$dir status --porcelain 2>/dev/null) ]]; then
      print -u2 "  warning: $dir has uncommitted changes"
    fi
  done

  cd $SNP_TEMP
  print "\n$SNP_TEMP  (back: cd \$SNP_BEFORE)"
}
