//
//  Copyright (c) 2014 Dblechoc. All rights reserved.
//

import Quick
import Nimble
import NearbyTramsKit
import NearbyTramsNetworkKit
import NearbyTramsStorageKit

class FakeStopsViewModelDelegate: StopsViewModelDelegate
{
    var addedStops: StopViewModel[]?
    var removedStops: StopViewModel[]?
    var updatedStops: StopViewModel[]?
    
    func stopsViewModelDidAddStops(stopsViewModel: StopsViewModel, stops: StopViewModel[])
    {
        addedStops = stops
    }
    
    func stopsViewModelDidRemoveStops(stopsViewModel: StopsViewModel, stops: StopViewModel[])
    {
        removedStops = stops
    }
    
    func stopsViewModelDidUpdateStops(stopsViewModel: StopsViewModel, stops: StopViewModel[])
    {
        updatedStops = stops
    }
}

class StopsViewModelSpec: QuickSpec {
    override func spec() {
        
        var store: CoreDataTestsHelperStore!
        var moc: NSManagedObjectContext!
        
        var fakeDelegate: FakeStopsViewModelDelegate!
        var viewModel: StopsViewModel!
        
        var fetchRequest: NSFetchRequest!
        
        beforeEach {
            store = CoreDataTestsHelperStore()
            moc = store.managedObjectContext
            
            viewModel = StopsViewModel(managedObjectContext: moc)
            fakeDelegate = FakeStopsViewModelDelegate()
            viewModel.delegate = fakeDelegate
            
            fetchRequest = NSFetchRequest(entityName: Stop.entityName)
            viewModel.startUpdatingStopsWithFetchRequest(fetchRequest)
        }
        
        afterEach {
            let success = moc.save(nil)
        }
        
        context("when empty") {
            it("should have no stops") {
                expect(viewModel.stops).to.beEmpty()
            }
            
            it("should have per stops count zero") {
                expect(viewModel.stopsCount).to.equal(0)
            }
        }
        
        describe("Adding stops") {
            context("when adding one stop") {
                beforeEach {
                    let route: Route = Route.insertInManagedObjectContext(moc)
                    route.routeNo = 123
                    route.uniqueIdentifier = "123-true"
                    route.destination = "destination"
                    
                    let stop: Stop = Stop.insertInManagedObjectContext(moc)
                    stop.uniqueIdentifier = "2166"
                    stop.stopNo = 2166
                    stop.destination = "a destination"
                    stop.routeNo = 123
                    stop.stopName = "a stop name"
                    stop.route = route
                    
                    moc.save(nil)
                }
                
                it("should have one stops") {
                    expect(viewModel.stops.count).to.equal(1)
                }
                
                it("should have per stops count one") {
                    expect(viewModel.stopsCount).to.equal(1)
                }
                
                it("should tell delegate about the added stop") {
                    expect(fakeDelegate.addedStops?[0].identifier).to.equal("2166")
                }
            }
            
            context("when adding one invalid stop") {
                beforeEach {
                    let stop: Stop = Stop.insertInManagedObjectContext(moc)
                    moc.save(nil)
                }
                
                it("should have no stops") {
                    expect(viewModel.stops).to.beEmpty()
                }
                
                it("should have per stops count zero") {
                    expect(viewModel.stopsCount).to.equal(0)
                }
            }
            
            context("when adding multiple stops") {
                beforeEach {
                    let route1: Route = Route.insertInManagedObjectContext(moc) as Route
                    route1.routeNo = 123
                    route1.uniqueIdentifier = "123-true"
                    route1.destination = "a destination"
                    
                    let stop1 = Stop.insertInManagedObjectContext(moc) as Stop
                    stop1.uniqueIdentifier = "2166"
                    stop1.stopNo = 2166
                    stop1.destination = "a destination"
                    stop1.routeNo = 123
                    stop1.stopName = "a stop name"
                    stop1.route = route1
                    
                    let route2: Route = Route.insertInManagedObjectContext(moc) as Route
                    route2.routeNo = 456
                    route2.uniqueIdentifier = "456-false"
                    route2.destination = "another destination"
                    
                    let stop2 = Stop.insertInManagedObjectContext(moc) as Stop
                    stop2.uniqueIdentifier = "3126"
                    stop2.stopNo = 2166
                    stop2.destination = "another destination"
                    stop2.routeNo = 123
                    stop2.stopName = "another stop name"
                    stop2.route = route2
                    
                    moc.save(nil)
                }
                
                it("should have one stops") {
                    expect(viewModel.stops.count).to.equal(2)
                }
                
                it("should have per stops count one") {
                    expect(viewModel.stopsCount).to.equal(2)
                }
                
                it("should tell delegate about the two added stop") {
                    let identifiers = [fakeDelegate.addedStops![0].identifier, fakeDelegate.addedStops![1].identifier]
                    expect(identifiers).to.contain("2166")
                    expect(identifiers).to.contain("3126")
                }
            }
        }
        
        describe("Removing stops") {
            var stop1: Stop!
            var stop2: Stop!
            
            beforeEach {
                let route1: Route = Route.insertInManagedObjectContext(moc) as Route
                route1.routeNo = 123
                route1.uniqueIdentifier = "123-true"
                route1.destination = "a destination"
                
                stop1 = Stop.insertInManagedObjectContext(moc) as Stop
                stop1.uniqueIdentifier = "2166"
                stop1.stopNo = 2166
                stop1.destination = "a destination"
                stop1.routeNo = 123
                stop1.stopName = "a stop name"
                stop1.route = route1
                
                let route2: Route = Route.insertInManagedObjectContext(moc) as Route
                route2.routeNo = 456
                route2.uniqueIdentifier = "456-false"
                route2.destination = "another destination"
                
                stop2 = Stop.insertInManagedObjectContext(moc) as Stop
                stop2.uniqueIdentifier = "3126"
                stop2.stopNo = 2166
                stop2.destination = "another destination"
                stop2.routeNo = 123
                stop2.stopName = "another stop name"
                stop2.route = route2
                
                moc.save(nil)
            }
            
            context("when removing one stop") {
                beforeEach {
                    moc.deleteObject(stop1)
                    moc.save(nil)
                }
                
                it("should have one stops") {
                    expect(viewModel.stops[0].identifier).to.equal("3126")
                }
                
                it("should have per stops count one") {
                    expect(viewModel.stopsCount).to.equal(1)
                }
                
                it("should tell delegate about the removed stop") {
                    expect(fakeDelegate.removedStops?[0].identifier).to.equal("2166")
                }
            }
            
            context("when removing multiple stops") {
                beforeEach {
                    moc.deleteObject(stop1)
                    moc.deleteObject(stop2)
                    moc.save(nil)
                }
                
                it("should have one stops") {
                    expect(viewModel.stops.count).to.equal(0)
                }
                
                it("should have per stops count one") {
                    expect(viewModel.stopsCount).to.equal(0)
                }
                
                it("should tell delegate about the two removed stop") {
                    let identifiers = [fakeDelegate.removedStops![0].identifier, fakeDelegate.removedStops![1].identifier]
                    expect(identifiers).to.contain("2166")
                    expect(identifiers).to.contain("3126")
                }
            }
        }
        
        describe("Updating stops") {
            var stop1: Stop!
            var stop2: Stop!
            
            beforeEach {
                let route1: Route = Route.insertInManagedObjectContext(moc) as Route
                route1.routeNo = 123
                route1.uniqueIdentifier = "123-true"
                route1.destination = "a destination"
                
                stop1 = Stop.insertInManagedObjectContext(moc) as Stop
                stop1.uniqueIdentifier = "2166"
                stop1.stopNo = 2166
                stop1.destination = "a destination"
                stop1.routeNo = 123
                stop1.stopName = "a stop name"
                stop1.route = route1
                
                let route2: Route = Route.insertInManagedObjectContext(moc) as Route
                route2.routeNo = 456
                route2.uniqueIdentifier = "456-false"
                route2.destination = "another destination"
                
                stop2 = Stop.insertInManagedObjectContext(moc) as Stop
                stop2.uniqueIdentifier = "3126"
                stop2.stopNo = 2166
                stop2.destination = "another destination"
                stop2.routeNo = 123
                stop2.stopName = "another stop name"
                stop2.route = route2
                
                moc.save(nil)
            }
            
            context("when updating one stop") {
                beforeEach {
                    stop1.destination = "new destination"
                    
                    moc.save(nil)
                }
                
                it("should tell delegate about the updated stop") {
                    expect(fakeDelegate.updatedStops?[0].identifier).to.equal("2166")
                }
            }
            
            context("when updating multiple stops") {
                beforeEach {
                    stop1.destination = "new destination"
                    stop2.destination = "another new destination"
                    
                    moc.save(nil)
                }
                
                it("should tell delegate about the two updated stop") {
                    let identifiers = [fakeDelegate.updatedStops![0].identifier, fakeDelegate.updatedStops![1].identifier]
                    expect(identifiers).to.contain("2166")
                    expect(identifiers).to.contain("3126")
                }
            }
        }
        
        
        describe("stopUpdatingStops") {
            beforeEach {
                viewModel.stopUpdatingStops()
                
                let route1: Route = Route.insertInManagedObjectContext(moc)
                route1.routeNo = 123
                route1.uniqueIdentifier = "123-true"
                route1.destination = "a destination"
                moc.save(nil)
            }
            
            it("should not tell delegate about the two added stop") {
                expect(fakeDelegate.addedStops?.count).to.beNil()
            }
        }
        
        describe("reconfiguring startUpdatingStopsWithFetchRequest") {
            context("when adding one stop") {
                beforeEach {
                    let route1: Route = Route.insertInManagedObjectContext(moc) as Route
                    route1.routeNo = 123
                    route1.uniqueIdentifier = "123-true"
                    route1.destination = "a destination"
                    
                    let stop1: Stop = Stop.insertInManagedObjectContext(moc) as Stop
                    stop1.uniqueIdentifier = "2166"
                    stop1.stopNo = 2166
                    stop1.destination = "a destination"
                    stop1.routeNo = 123
                    stop1.stopName = "a stop name"
                    stop1.route = route1
                    
                    let route2: Route = Route.insertInManagedObjectContext(moc) as Route
                    route2.routeNo = 456
                    route2.uniqueIdentifier = "456-false"
                    route2.destination = "another destination"
                    
                    let stop2: Stop = Stop.insertInManagedObjectContext(moc) as Stop
                    stop2.uniqueIdentifier = "3126"
                    stop2.stopNo = 2166
                    stop2.destination = "another destination"
                    stop2.routeNo = 123
                    stop2.stopName = "another stop name"
                    stop2.route = route2
                    
                    moc.save(nil)
                    
                    fetchRequest = NSFetchRequest(entityName: Stop.entityName)
                    fetchRequest.predicate = NSPredicate(format:"uniqueIdentifier == %@", "2166")
                    viewModel.startUpdatingStopsWithFetchRequest(fetchRequest)
                    
                    let route3: Route = Route.insertInManagedObjectContext(moc)
                    route3.routeNo = 789
                    route3.uniqueIdentifier = "789-true"
                    route3.destination = "a third destination"
                    
                    let stop3: Stop = Stop.insertInManagedObjectContext(moc) as Stop
                    stop3.uniqueIdentifier = "4589"
                    stop3.stopNo = 2166
                    stop3.destination = "ta third destination"
                    stop3.routeNo = 456
                    stop3.stopName = "a third stop name"
                    stop3.route = route3
                    
                    moc.save(nil)
                }
                
                it("should have one stops") {
                    expect(viewModel.stops.count).to.equal(1)
                }
                
                it("should have per stops count one") {
                    expect(viewModel.stopsCount).to.equal(1)
                }
                
                it("should tell delegate about the added stops") {
                    let identifiers = [fakeDelegate.addedStops![0].identifier, fakeDelegate.addedStops![1].identifier]
                    expect(identifiers).to.contain("2166")
                    expect(identifiers).to.contain("3126")
                }
                
                it("should tell delegate about the updated stop") {
                    expect(fakeDelegate.updatedStops?[0].identifier).to.equal("2166")
                }
                
                it("should tell delegate about the removed stop") {
                    expect(fakeDelegate.removedStops?[0].identifier).to.equal("3126")
                }
            }
        }
    }
}
