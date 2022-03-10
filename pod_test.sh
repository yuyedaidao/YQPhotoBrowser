git tag -d '0.4.0'
git push -d origin '0.4.0'
git add -A
git commit -m 'update rb'
git push 
git tag '0.4.0'
git push --tags
pod lib lint --verbose