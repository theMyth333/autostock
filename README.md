## Unit 3 - Deploying the app to BTP Cloud Foundry Environment

### Pre-requisites 


### Instruction
1. cds add xsuaa
review changes

2. add xs-security.json

3. update approuter in xs-app.json

4. validate
npx cds compile srv --to edmx
npx cds build --production

5. mbt build -t .

6. deploy 
cf deploy .\autostock_1.0.0.mtar

7. Create and assign role collections

### Project Structure

### Concepts

### Exercises
