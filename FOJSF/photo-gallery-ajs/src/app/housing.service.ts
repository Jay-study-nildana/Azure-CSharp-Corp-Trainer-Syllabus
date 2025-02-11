import { Injectable } from '@angular/core';
import { HousingLocation } from './housinglocation';

@Injectable({
  providedIn: 'root'
})
export class HousingService {
  readonly baseUrl = 'assets/images';

  protected housingLocationList: HousingLocation[] = [
    {
      id: 0,
      name: 'A woman with a bright smile and short hair',
      city: 'Emily',
      state: '19',
      photo: `${this.baseUrl}/one.jpg`,
      availableUnits: 4,
      wifi: true,
      laundry: true
    },
    {
      id: 1,
      name: 'A woman with long hair and glasses',
      city: 'Sophia',
      state: '22',
      photo: `${this.baseUrl}/two.jpg`,
      availableUnits: 0,
      wifi: false,
      laundry: true
    },
    {
      id: 2,
      name: 'A woman with curly hair and a warm smile',
      city: 'Olivia',
      state: '24',
      photo: `${this.baseUrl}/three.jpg`,
      availableUnits: 1,
      wifi: false,
      laundry: false
    },
    {
      id: 3,
      name: 'A woman with a serious expression and straight hair',
      city: 'Ava',
      state: '21',
      photo: `${this.baseUrl}/four.jpg`,
      availableUnits: 1,
      wifi: true,
      laundry: false
    }
  ];

  getAllHousingLocations(): HousingLocation[] {
    return this.housingLocationList;
  }

  getHousingLocationById(id: number): HousingLocation | undefined {
    return this.housingLocationList.find(housingLocation => housingLocation.id === id);
  }

  submitApplication(firstName: string, lastName: string, email: string) {
    console.log(`Homes application received: firstName: ${firstName}, lastName: ${lastName}, email: ${email}.`);
  }
}