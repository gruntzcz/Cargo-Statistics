class CargoStats extends GSController
{
    _company = GSCompany.COMPANY_FIRST;

    _cargo_list = null;
    _transported = null;
    _elements = null;

    _page = GSStoryPage.STORY_PAGE_INVALID;

    _loaded = false;


    function Start()
    {
        GSLog.Info("Cargo Statistics started!");

        this._cargo_list = GSCargoList();

        /*
         * New game:
         * create empty storage.
         *
         * Loaded game:
         * _transported, _page and _elements were restored by Load().
         */
        if (!this._loaded)
        {
            this._transported = {};
            this._elements = {};

            foreach (cargo, _ in this._cargo_list)
            {
                this._transported[cargo] <- 0;
            }
        }
        else
        {
            /*
             * A NewGRF or another change could theoretically add
             * a cargo type which was not present in the saved table.
             * Make sure every currently available cargo has a counter.
             */
            foreach (cargo, _ in this._cargo_list)
            {
                if (!this._transported.rawin(cargo))
                {
                    this._transported[cargo] <- 0;
                }
            }
        }


        /*
         * Try to reuse the existing Story Book page.
         * If it doesn't exist, create a new one.
         */
        if (
            this._page == GSStoryPage.STORY_PAGE_INVALID ||
            !GSStoryPage.IsValidStoryPage(this._page)
        )
        {
            this._page = GSStoryPage.New(
                GSCompany.COMPANY_INVALID,
                "Cargo Statistics"
            );

            this._elements = {};
        }


        if (this._page == GSStoryPage.STORY_PAGE_INVALID)
        {
            GSLog.Error("Could not create Story Book page.");
            return;
        }


        /*
         * Hide the date shown at the top of the Story Book page.
         */
        GSStoryPage.SetDate(
            this._page,
            GSDate.DATE_INVALID
        );


        /*
         * Create missing Story Book rows.
         * Existing rows from a savegame are reused.
         */
        foreach (cargo, _ in this._cargo_list)
        {
            local valid_element = false;

            if (this._elements.rawin(cargo))
            {
                local element = this._elements[cargo];

                if (GSStoryPage.IsValidStoryPageElement(element))
                {
                    valid_element = true;
                }
            }


            if (!valid_element)
            {
                local name = GSCargo.GetName(cargo);
                local amount = this._transported[cargo];

                local element = GSStoryPage.NewElement(
                    this._page,
                    GSStoryPage.SPET_TEXT,
                    0,
                    name + ": " + amount
                );

                this._elements[cargo] <- element;
            }
        }


        /*
         * Update the visible values immediately after loading.
         */
        this.UpdateStoryBook();


        while (true)
        {
            this.UpdateStatistics();
            this.UpdateStoryBook();

            this.Sleep(74 * 5);
        }
    }


    function UpdateStatistics()
    {
        local company = GSCompany.ResolveCompanyID(this._company);

        if (company == GSCompany.COMPANY_INVALID)
        {
            return;
        }

        local town_list = GSTownList();

        foreach (cargo, _ in this._cargo_list)
        {
            local transported = 0;

            foreach (town_id, _ in town_list)
            {
                local amount = GSCargoMonitor.GetTownDeliveryAmount(
                    company,
                    cargo,
                    town_id,
                    true
                );

                if (amount > 0)
                {
                    transported += amount;
                }
            }

            this._transported[cargo] += transported;
        }
    }


    function UpdateStoryBook()
    {
        foreach (cargo, _ in this._cargo_list)
        {
            if (!this._elements.rawin(cargo))
            {
                continue;
            }

            local element = this._elements[cargo];

            if (!GSStoryPage.IsValidStoryPageElement(element))
            {
                continue;
            }

            local name = GSCargo.GetName(cargo);
            local amount = this._transported[cargo];

            GSStoryPage.UpdateElement(
                element,
                0,
                name + ": " + amount
            );
        }
    }


    function Save()
    {
        GSLog.Info("Saving Cargo Statistics.");

        return {
            transported = this._transported,
            page = this._page,
            elements = this._elements
        };
    }


    function Load(version, data)
    {
        GSLog.Info(
            "Loading Cargo Statistics from script version " + version
        );

        this._transported = {};
        this._elements = {};

        if (data.rawin("transported"))
        {
            foreach (cargo, amount in data.transported)
            {
                this._transported.rawset(cargo, amount);
            }
        }

        if (data.rawin("elements"))
        {
            foreach (cargo, element in data.elements)
            {
                this._elements.rawset(cargo, element);
            }
        }

        if (data.rawin("page"))
        {
            this._page = data.page;
        }
        else
        {
            this._page = GSStoryPage.STORY_PAGE_INVALID;
        }

        this._loaded = true;
    }
}