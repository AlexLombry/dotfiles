# Development Helpers

# Xcode via @orta
openx() {
  if [ -n "$(fd -e xcworkspace --max-depth 1)" ]; then
    echo "Opening workspace"
    open *.xcworkspace
  elif [ -n "$(fd -e xcodeproj --max-depth 1)" ]; then
    echo "Opening project"
    open *.xcodeproj
  else
    echo "Nothing found"
  fi
}
