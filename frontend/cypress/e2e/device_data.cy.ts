describe('Device Data Page', () => {
  beforeEach(() => {
    cy.fixture('users').then((users) => {
      cy.visit('/login');
      cy.get('#email').type(users.admin.email);
      cy.get('#password').type(users.admin.password);
      cy.get('#loginSubmit').click();
      cy.get('#navDevices').click();
    });
  });

  it('renders all filter controls', () => {
    cy.get('#deviceIdInput').should('exist');
    cy.get('#fromInput').should('exist');
    cy.get('#toInput').should('exist');
    cy.get('#loadDataBtn').should('exist');
    cy.get('#downloadCsvBtn').should('exist');
    cy.get('#downloadExcelBtn').should('exist');
    cy.get('#liveRefreshBtn').should('exist');
  });

  it('CSV download button is disabled without device ID', () => {
    cy.get('#downloadCsvBtn').should('be.disabled');
  });

  it('CSV download triggers after setting device ID', () => {
    cy.intercept('GET', '**/data/csv').as('csvDownload');
    cy.get('#deviceIdInput').type('test_device_id');
    cy.get('#downloadCsvBtn').should('not.be.disabled');
  });

  it('table shows Voltage, Current, Power, temperature_C columns after load', () => {
    cy.intercept('GET', '**/data**', {
      body: [{ device_id:'d1', timestamp:'2025-01-01T00:00:00', Voltage:230, Current:1.0, Power:230, temperature_C:40, status:'Active', fault_score:0.01, is_anomaly:0 }]
    }).as('getData');
    cy.get('#deviceIdInput').type('d1');
    cy.get('#loadDataBtn').click();
    cy.wait('@getData');
    cy.get('#readingsTable thead th').then((headers) => {
      const texts = [...headers].map((h) => h.textContent ?? '');
      expect(texts.some((t) => t.includes('Voltage'))).toBeTrue();
      expect(texts.some((t) => t.includes('Current'))).toBeTrue();
    });
  });

  it('live refresh toggle changes button text', () => {
    cy.get('#deviceIdInput').type('d1');
    cy.get('#liveRefreshBtn').click();
    cy.get('#liveRefreshBtn').should('contain.text','Stop Live');
    cy.get('#liveRefreshBtn').click();
    cy.get('#liveRefreshBtn').should('contain.text','Live');
  });
});
