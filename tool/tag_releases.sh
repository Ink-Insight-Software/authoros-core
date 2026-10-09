#!/usr/bin/env bash
# Tags each released version: the first commit on main's first-parent line
# whose pubspec.yaml carries it, as README "Releasing" step 3 says. A version
# that already has a tag is left alone; nothing is moved or deleted.
#
#   tool/tag_releases.sh          prints what it would tag
#   tool/tag_releases.sh --push   creates the tags and pushes them
set -euo pipefail

push=false
[ "${1:-}" = "--push" ] && push=true
branch="${TAG_BRANCH:-origin/main}"

declare -A seen=()
created=()
while read -r commit; do
  version="$(git show "$commit:pubspec.yaml" 2>/dev/null \
    | sed -n "s/^version:[[:space:]]*//p" | tr -d "\r" | head -n1 || true)"
  [ -n "$version" ] || continue
  [ -z "${seen[$version]:-}" ] || continue
  seen[$version]=1
  tag="v$version"
  if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    continue
  fi
  echo "$tag -> $(git log -1 --format='%h %s' "$commit")"
  if $push; then
    git tag "$tag" "$commit"
    created+=("$tag")
  fi
done < <(git log --first-parent --reverse --format=%H "$branch")

if $push && [ "${#created[@]}" -gt 0 ]; then
  git push origin "${created[@]}"
fi
[ "${#seen[@]}" -gt 0 ] || { echo "No version found on $branch." >&2; exit 1; }
