string='My long string 123:123'
if [[ $string == *"13:123"* ]]; then
  echo "It's there!"
fi
