# sf-food-trucks
API Service to view food trucks and push carts in San Francisco

### Running the project locally:
1. Check if you have **asdf** installed. If not go through the [installation steps](https://asdf-vm.com/guide/getting-started.html)
2. Inside the project root run 
```
$ asdf install
```
3. Install dependecies
```
$ mix deps.get
```
4. Run tests
```
$ MIX_ENV=test mix test
```
5. Run the project
```
mix phx.server
```
6. Check your data at `localhost:4000/api/permits` url

### Project Roadmap:

- [x] Basic Implementation
- [ ] Caching to a file
- [ ] Caching to a database
- [ ] Fecthing permits [working time](https://data.sfgov.org/Economy-and-Community/Mobile-Food-Schedule/jjew-r69b/about_data)
- [ ] Fulltext search support
- [ ] Filters support
- [ ] Search by nearest geoposition