## Unit 3 - Deploying the app to BTP Cloud Foundry Environment

### Pre-requisites 
- BTP Trial Account
- CF install => cf target
- Create Postgres Instance => cf services
- MBT install

node --version
npm --version
cds --version
cf --version
mbt --version
make --version

```
cf login -a https://api.cf.us10-001.hana.ondemand.com -u mithunkarthick3@gmail.com -p <PASSWORD>
```



### Instruction
1. cds add postgres --for production
2. cds add mta
3. change dev to trial in mta file
4. cds build --production
5. mbt build -t .

6. cd app\autostock
npx ui5 build --all --clean-dest --dest dist
7. cds add approuter
### Project Structure

### Concepts

### Exercises
